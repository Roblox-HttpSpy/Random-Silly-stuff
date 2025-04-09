local StrToNumber = tonumber;
local Byte = string.byte;
local Char = string.char;
local Sub = string.sub;
local Subg = string.gsub;
local Rep = string.rep;
local Concat = table.concat;
local Insert = table.insert;
local LDExp = math.ldexp;
local GetFEnv = getfenv or function()
	return _ENV;
end;
local Setmetatable = setmetatable;
local PCall = pcall;
local Select = select;
local Unpack = unpack or table.unpack;
local ToNumber = tonumber;
local function VMCall(ByteString, vmenv, ...)
	local DIP = 1;
	local repeatNext;
	ByteString = Subg(Sub(ByteString, 5), "..", function(byte)
		if (Byte(byte, 2) == 81) then
			repeatNext = StrToNumber(Sub(byte, 1, 1));
			return "";
		else
			local a = Char(StrToNumber(byte, 16));
			if repeatNext then
				local b = Rep(a, repeatNext);
				repeatNext = nil;
				return b;
			else
				return a;
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
			return Res - (Res % 1);
		else
			local Plc = 2 ^ (Start - 1);
			return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
		end
	end
	local function gBits8()
		local a = Byte(ByteString, DIP, DIP);
		DIP = DIP + 1;
		return a;
	end
	local function gBits16()
		local a, b = Byte(ByteString, DIP, DIP + 2);
		DIP = DIP + 2;
		return (b * 256) + a;
	end
	local function gBits32()
		local a, b, c, d = Byte(ByteString, DIP, DIP + 3);
		DIP = DIP + 4;
		return (d * 16777216) + (c * 65536) + (b * 256) + a;
	end
	local function gFloat()
		local Left = gBits32();
		local Right = gBits32();
		local IsNormal = 1;
		local Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
		local Exponent = gBit(Right, 21, 31);
		local Sign = ((gBit(Right, 32) == 1) and -1) or 1;
		if (Exponent == 0) then
			if (Mantissa == 0) then
				return Sign * 0;
			else
				Exponent = 1;
				IsNormal = 0;
			end
		elseif (Exponent == 2047) then
			return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
		end
		return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
	end
	local function gString(Len)
		local Str;
		if not Len then
			Len = gBits32();
			if (Len == 0) then
				return "";
			end
		end
		Str = Sub(ByteString, DIP, (DIP + Len) - 1);
		DIP = DIP + Len;
		local FStr = {};
		for Idx = 1, #Str do
			FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
		end
		return Concat(FStr);
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local Instrs = {};
		local Functions = {};
		local Lines = {};
		local Chunk = {Instrs,Functions,nil,Lines};
		local ConstCount = gBits32();
		local Consts = {};
		for Idx = 1, ConstCount do
			local Type = gBits8();
			local Cons;
			if (Type == 1) then
				Cons = gBits8() ~= 0;
			elseif (Type == 2) then
				Cons = gFloat();
			elseif (Type == 3) then
				Cons = gString();
			end
			Consts[Idx] = Cons;
		end
		Chunk[3] = gBits8();
		for Idx = 1, gBits32() do
			local Descriptor = gBits8();
			if (gBit(Descriptor, 1, 1) == 0) then
				local Type = gBit(Descriptor, 2, 3);
				local Mask = gBit(Descriptor, 4, 6);
				local Inst = {gBits16(),gBits16(),nil,nil};
				if (Type == 0) then
					Inst[3] = gBits16();
					Inst[4] = gBits16();
				elseif (Type == 1) then
					Inst[3] = gBits32();
				elseif (Type == 2) then
					Inst[3] = gBits32() - (2 ^ 16);
				elseif (Type == 3) then
					Inst[3] = gBits32() - (2 ^ 16);
					Inst[4] = gBits16();
				end
				if (gBit(Mask, 1, 1) == 1) then
					Inst[2] = Consts[Inst[2]];
				end
				if (gBit(Mask, 2, 2) == 1) then
					Inst[3] = Consts[Inst[3]];
				end
				if (gBit(Mask, 3, 3) == 1) then
					Inst[4] = Consts[Inst[4]];
				end
				Instrs[Idx] = Inst;
			end
		end
		for Idx = 1, gBits32() do
			Functions[Idx - 1] = Deserialize();
		end
		return Chunk;
	end
	local function Wrap(Chunk, Upvalues, Env)
		local Instr = Chunk[1];
		local Proto = Chunk[2];
		local Params = Chunk[3];
		return function(...)
			local Instr = Instr;
			local Proto = Proto;
			local Params = Params;
			local _R = _R;
			local VIP = 1;
			local Top = -1;
			local Vararg = {};
			local Args = {...};
			local PCount = Select("#", ...) - 1;
			local Lupvals = {};
			local Stk = {};
			for Idx = 0, PCount do
				if (Idx >= Params) then
					Vararg[Idx - Params] = Args[Idx + 1];
				else
					Stk[Idx] = Args[Idx + 1];
				end
			end
			local Varargsz = (PCount - Params) + 1;
			local Inst;
			local Enum;
			while true do
				Inst = Instr[VIP];
				Enum = Inst[1];
				if (Enum <= 18) then
					if (Enum <= 8) then
						if (Enum <= 3) then
							if (Enum <= 1) then
								if (Enum == 0) then
									if Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								end
							elseif (Enum == 2) then
								local A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
							else
								Stk[Inst[2]] = Upvalues[Inst[3]];
							end
						elseif (Enum <= 5) then
							if (Enum == 4) then
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							else
								local A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							end
						elseif (Enum <= 6) then
							Stk[Inst[2]] = {};
						elseif (Enum > 7) then
							Stk[Inst[2]] = Env[Inst[3]];
						else
							Stk[Inst[2]] = Env[Inst[3]];
						end
					elseif (Enum <= 13) then
						if (Enum <= 10) then
							if (Enum == 9) then
								local NewProto = Proto[Inst[3]];
								local NewUvals;
								local Indexes = {};
								NewUvals = Setmetatable({}, {__index=function(_, Key)
									local Val = Indexes[Key];
									return Val[1][Val[2]];
								end,__newindex=function(_, Key, Value)
									local Val = Indexes[Key];
									Val[1][Val[2]] = Value;
								end});
								for Idx = 1, Inst[4] do
									VIP = VIP + 1;
									local Mvm = Instr[VIP];
									if (Mvm[1] == 10) then
										Indexes[Idx - 1] = {Stk,Mvm[3]};
									else
										Indexes[Idx - 1] = {Upvalues,Mvm[3]};
									end
									Lupvals[#Lupvals + 1] = Indexes;
								end
								Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
							else
								Stk[Inst[2]] = Stk[Inst[3]];
							end
						elseif (Enum <= 11) then
							local NewProto = Proto[Inst[3]];
							local NewUvals;
							local Indexes = {};
							NewUvals = Setmetatable({}, {__index=function(_, Key)
								local Val = Indexes[Key];
								return Val[1][Val[2]];
							end,__newindex=function(_, Key, Value)
								local Val = Indexes[Key];
								Val[1][Val[2]] = Value;
							end});
							for Idx = 1, Inst[4] do
								VIP = VIP + 1;
								local Mvm = Instr[VIP];
								if (Mvm[1] == 10) then
									Indexes[Idx - 1] = {Stk,Mvm[3]};
								else
									Indexes[Idx - 1] = {Upvalues,Mvm[3]};
								end
								Lupvals[#Lupvals + 1] = Indexes;
							end
							Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
						elseif (Enum == 12) then
							local A = Inst[2];
							local B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
						else
							local A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
						end
					elseif (Enum <= 15) then
						if (Enum > 14) then
							Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
						else
							Stk[Inst[2]] = {};
						end
					elseif (Enum <= 16) then
						do
							return;
						end
					elseif (Enum > 17) then
						Stk[Inst[2]][Inst[3]] = Inst[4];
					else
						local A = Inst[2];
						Stk[A] = Stk[A](Stk[A + 1]);
					end
				elseif (Enum <= 28) then
					if (Enum <= 23) then
						if (Enum <= 20) then
							if (Enum > 19) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							else
								local A = Inst[2];
								Stk[A](Stk[A + 1]);
							end
						elseif (Enum <= 21) then
							VIP = Inst[3];
						elseif (Enum == 22) then
							local A = Inst[2];
							local B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
						else
							local A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
						end
					elseif (Enum <= 25) then
						if (Enum > 24) then
							Stk[Inst[2]] = Inst[3];
						else
							Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
						end
					elseif (Enum <= 26) then
						VIP = Inst[3];
					elseif (Enum > 27) then
						local A = Inst[2];
						Stk[A](Stk[A + 1]);
					elseif not Stk[Inst[2]] then
						VIP = VIP + 1;
					else
						VIP = Inst[3];
					end
				elseif (Enum <= 33) then
					if (Enum <= 30) then
						if (Enum > 29) then
							Stk[Inst[2]] = Inst[3];
						else
							Stk[Inst[2]] = Upvalues[Inst[3]];
						end
					elseif (Enum <= 31) then
						Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
					elseif (Enum > 32) then
						Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
					else
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
					end
				elseif (Enum <= 35) then
					if (Enum > 34) then
						if Stk[Inst[2]] then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					elseif not Stk[Inst[2]] then
						VIP = VIP + 1;
					else
						VIP = Inst[3];
					end
				elseif (Enum <= 36) then
					do
						return;
					end
				elseif (Enum > 37) then
					Stk[Inst[2]][Inst[3]] = Inst[4];
				else
					local A = Inst[2];
					Stk[A](Unpack(Stk, A + 1, Inst[3]));
				end
				VIP = VIP + 1;
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!193Q0003043Q0067616D6503073Q00506C6179657273030B3Q004C6F63616C506C6179657203043Q005465616D030A3Q004765745365727669636503053Q005465616D7303043Q00426C75652Q012Q033Q00526564030A3Q005374617274657247756903073Q00536574436F726503103Q0053656E644E6F74696669636174696F6E03053Q005469746C6503083Q0061792042752Q647903043Q0054657874031D3Q00596F7520676F2Q74612073656C6563742061207465616D20666972737403083Q004475726174696F6E03023Q00313903053Q007063612Q6C03163Q00427970612Q73656420416E74694368656174F09FA580030D3Q004855483F206661696C65643F21033A3Q004D61646520627920482Q74707320286F7220482Q74705370792C2077686174206576657220796F752077612Q6E612063612Q6C206D65293Q2E033D3Q007765726520796F7520747279696E6720746F2065786563757465207468652073616D65207363726970742074776963653F3Q2E2062726F207768617403023Q002Q3103023Q003135003E3Q0012083Q00013Q002Q205Q0002002Q205Q0003002Q2000013Q00042Q000E00023Q0002001208000300013Q00200C00030003000500121E000500064Q0005000300050002002Q20000300030007002018000200030008001208000300013Q00200C00030003000500121E000500064Q0005000300050002002Q200003000300090020180002000300082Q000F0003000200010006220003001E000100010004153Q001E0001001208000300013Q002Q2000030003000A00200C00030003000B00121E0005000C4Q000E00063Q00030030120006000D000E0030120006000F00100030120006001100122Q00250003000600012Q00103Q00013Q001208000300133Q00060900043Q000100012Q000A8Q0011000300020002001208000400013Q002Q2000040004000A00200C00040004000B00121E0006000C4Q000E00073Q000300062Q0003002C00013Q0004153Q002C000100121E000800143Q0006220008002D000100010004153Q002D000100121E000800153Q0010010007000D000800062Q0003003300013Q0004153Q0033000100121E000800163Q00062200080034000100010004153Q0034000100121E000800173Q0010010007000F000800062Q0003003A00013Q0004153Q003A000100121E000800183Q0006220008003B000100010004153Q003B000100121E000800193Q0010010007001100082Q00250004000700012Q00103Q00013Q00013Q000F3Q0003043Q0067616D65030A3Q004765745365727669636503113Q005265706C69636174656453746F7261676503063Q004576656E747303063Q0052656D6F7465030A3Q0053656C665265706F727403073Q0044657374726F7903093Q00576F726B7370616365030E3Q0046696E6446697273744368696C6403043Q004E616D65030F3Q004C5F4F7074696D697A6174696F6E7303083Q0044697361626C65642Q0103073Q004D6F64756C6573030A3Q004D5F4E6F74696669657200203Q0012083Q00013Q00200C5Q000200121E000200034Q00053Q00020002002Q205Q0004002Q205Q0005002Q205Q000600200C5Q00072Q001C3Q000200010012083Q00013Q002Q205Q000800200C5Q00092Q000300025Q002Q2000020002000A2Q00053Q0002000200064Q001700013Q0004153Q0017000100200C00013Q000900121E0003000B4Q000500010003000200062Q0001001700013Q0004153Q001700010030120001000C000D001208000100013Q00200C00010001000200121E000300034Q0005000100030002002Q2000010001000E002Q2000010001000F00200C0001000100072Q001C0001000200012Q00103Q00017Q00", GetFEnv(), ...);
