require "luasql.postgres" -- for database
require "SEL_Cevent"
local my_ge_comtrade = require("luaGEComtrade")

local active_config

function DefaultStartFunction()
	orion.SetPoint({name="1 @Logic", value = 1, online=true})
	orion.SetPoint({name="RELAY_TAB @Logic", value=0, online=true})
	
	NCD_File_get_active_filename()
	NCD_File_build_Zone_Alarm_Table()
	NCD_File_put_pseudo_points_online()
	
	InitSELEvent(g_SEL_event_dir)
	my_ge_comtrade.initialize("/etc/orion/GEComtradeFiles", "/etc/orion/GEComtradeTemp")
end

g_SEL_event_dir = "/etc/orion/SELevent" -- directory to save event files to
g_bkr_normal = 1 -- normal state for breakers. 1 for closed. 0 for open. assumes same behavior for all devices
g_event_length = 10000 --expected length of cevent file. testing shows between 7000-8000 on average
g_2030_0_fd = nil -- for testing
g_2030_1_fd = nil
g_2030_2_fd = nil
g_2030_3_fd = nil
g_2030_4_fd = nil
g_cr = "\n\r" --carriage return
g_ctrld = "\4" -- ctrl-d
g_SEL_timeout = 5 --seconds to wait for rx and tx confirmation
g_SEL_reset = 5 --how many timeouts before resetting to beginning of state machine
g_SEL_retries = 3 -- how many resets before giving up on a given feeder all together
g_temp_event_file = "/temp_cevent.log" -- temporary filename to save event to. Gets renamed in rename_event_file


tbl_SEL = {}
tbl_SEL[1] = {name="11A", host="172.16.154.80", Pass2030="Wh655.", Port2030=1, PassRelay="Wh655.", fd=g_2030_1_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[2] = {name="12A", host="172.16.154.80", Pass2030="Wh655.", Port2030=2, PassRelay="Wh655.", fd=g_2030_1_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[3] = {name="13A", host="172.16.154.80", Pass2030="Wh655.", Port2030=3, PassRelay="Wh655.", fd=g_2030_1_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[4] = {name="14A", host="172.16.154.80", Pass2030="Wh655.", Port2030=4, PassRelay="Wh655.", fd=g_2030_1_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[5] = {name="11B", host="172.16.154.80", Pass2030="Wh655.", Port2030=5, PassRelay="Wh655.", fd=g_2030_1_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[6] = {name="12B", host="172.16.154.80", Pass2030="Wh655.", Port2030=6, PassRelay="Wh655.", fd=g_2030_1_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[7] = {name="13B", host="172.16.154.80", Pass2030="Wh655.", Port2030=7, PassRelay="Wh655.", fd=g_2030_1_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[8] = {name="14B(C3)", host="172.16.154.80", Pass2030="Wh655.", Port2030=8, PassRelay="Wh655.", fd=g_2030_1_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[9] = {name="21A", host="172.168.154.81", Pass2030="Wh655.", Port2030=1, PassRelay="Wh655.", fd=g_2030_2_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[10] = {name="22A", host="172.168.154.81", Pass2030="Wh655.", Port2030=2, PassRelay="Wh655.", fd=g_2030_2_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[11] = {name="23A", host="172.168.154.81", Pass2030="Wh655.", Port2030=3, PassRelay="Wh655.", fd=g_2030_2_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[12] = {name="24A", host="172.168.154.81", Pass2030="Wh655.", Port2030=4, PassRelay="Wh655.", fd=g_2030_2_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[13] = {name="21B", host="172.168.154.81", Pass2030="Wh655.", Port2030=5, PassRelay="Wh655.", fd=g_2030_2_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[14] = {name="22B", host="172.168.154.81", Pass2030="Wh655.", Port2030=6, PassRelay="Wh655.", fd=g_2030_2_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[15] = {name="23B", host="172.168.154.81", Pass2030="Wh655.", Port2030=7, PassRelay="Wh655.", fd=g_2030_2_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[16] = {name="24B", host="172.168.154.81", Pass2030="Wh655.", Port2030=8, PassRelay="Wh655.", fd=g_2030_2_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[17] = {name="C2", host="172.168.154.81", Pass2030="Wh655.", Port2030=9, PassRelay="Wh655.", fd=g_2030_2_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[18] = {name="C1", host="172.168.154.81", Pass2030="Wh655.", Port2030=10, PassRelay="Wh655.", fd=g_2030_2_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[19] = {name="31A", host="172.168.154.82", Pass2030="Wh655.", Port2030=1, PassRelay="Wh655.", fd=g_2030_3_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[20] = {name="32A", host="172.168.154.82", Pass2030="Wh655.", Port2030=2, PassRelay="Wh655.", fd=g_2030_3_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[21] = {name="33A", host="172.168.154.82", Pass2030="Wh655.", Port2030=3, PassRelay="Wh655.", fd=g_2030_3_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[22] = {name="34A", host="172.168.154.82", Pass2030="Wh655.", Port2030=4, PassRelay="Wh655.", fd=g_2030_3_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[23] = {name="31B", host="172.168.154.82", Pass2030="Wh655.", Port2030=5, PassRelay="Wh655.", fd=g_2030_3_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[24] = {name="32B", host="172.168.154.82", Pass2030="Wh655.", Port2030=6, PassRelay="Wh655.", fd=g_2030_3_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[25] = {name="33B", host="172.168.154.82", Pass2030="Wh655.", Port2030=7, PassRelay="Wh655.", fd=g_2030_3_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[26] = {name="34B", host="172.168.154.82", Pass2030="Wh655.", Port2030=8, PassRelay="Wh655.", fd=g_2030_3_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[27] = {name="41A", host="172.168.154.83", Pass2030="Wh655.", Port2030=1, PassRelay="Wh655.", fd=g_2030_4_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[28] = {name="42A", host="172.168.154.83", Pass2030="Wh655.", Port2030=2, PassRelay="Wh655.", fd=g_2030_4_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[29] = {name="43A", host="172.168.154.83", Pass2030="Wh655.", Port2030=3, PassRelay="Wh655.", fd=g_2030_4_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[30] = {name="44A", host="172.168.154.83", Pass2030="Wh655.", Port2030=4, PassRelay="Wh655.", fd=g_2030_4_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[31] = {name="41B", host="172.168.154.83", Pass2030="Wh655.", Port2030=5, PassRelay="Wh655.", fd=g_2030_4_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[32] = {name="42B", host="172.168.154.83", Pass2030="Wh655.", Port2030=6, PassRelay="Wh655.", fd=g_2030_4_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[33] = {name="43B", host="172.168.154.83", Pass2030="Wh655.", Port2030=7, PassRelay="Wh655.", fd=g_2030_4_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}
tbl_SEL[34] = {name="44B", host="172.168.154.83", Pass2030="Wh655.", Port2030=8, PassRelay="Wh655.", fd=g_2030_4_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}

tbl_SEL[100] = {name="TestFeeder1", host="172.168.154.190", Pass2030="OTTER", Port2030=2, PassRelay="OTTER", fd=g_2030_0_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}--test connection
tbl_SEL[101] = {name="TestFeeder2", host="172.168.154.190", Pass2030="OTTER", Port2030=8, PassRelay="OTTER", fd=g_2030_0_fd, addr=0, port=23, state=0, time=os.time(), fails=0, retries=0}--test connection

tbl_SEL_Queue = {} -- queue for events as they come in

tbl_GERelays = {}
tbl_GERelays[1] = {Name="F60-C3-B",IP="172.168.154.16",ModbusAddress=16,PointName="C3/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_1",OldValue=99999,PendingEvent=false}
tbl_GERelays[2] = {Name="F60-13B-B",IP="172.168.154.17",ModbusAddress=17,PointName="13B/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_1",OldValue=99999,PendingEvent=false}
tbl_GERelays[3] = {Name="F60-12B-B",IP="172.168.154.18",ModbusAddress=18,PointName="12B/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_1",OldValue=99999,PendingEvent=false}
tbl_GERelays[4] = {Name="F60-11B-B",IP="172.168.154.19",ModbusAddress=19,PointName="11B/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_1",OldValue=99999,PendingEvent=false}
tbl_GERelays[5] = {Name="F35-87-1B-B",IP="172.168.154.20",ModbusAddress=20,PointName="1W/87 (F35) OSCILLOGRAPHY TRIGGER COUNT @D20_1",OldValue=99999,PendingEvent=false}
tbl_GERelays[6] = {Name="F35-51-1B-B",IP="172.168.154.21",ModbusAddress=21,PointName="1W/51 (F35) OSCILLOGRAPHY TRIGGER COUNT @D20_1",OldValue=99999,PendingEvent=false}
tbl_GERelays[7] = {Name="F60-14A-B",IP="172.168.154.22",ModbusAddress=22,PointName="14A/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_1",OldValue=99999,PendingEvent=false}
tbl_GERelays[8] = {Name="F60-13A-B",IP="172.168.154.23",ModbusAddress=23,PointName="13A/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_1",OldValue=99999,PendingEvent=false}
tbl_GERelays[9] = {Name="F60-12A-B",IP="172.168.154.24",ModbusAddress=24,PointName="12A/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_1",OldValue=99999,PendingEvent=false}
tbl_GERelays[10] = {Name="F60-LP2-B",IP="172.168.154.25",ModbusAddress=25,PointName="LP2/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_1",OldValue=99999,PendingEvent=false}
tbl_GERelays[11] = {Name="F35-87-1A-B",IP="172.168.154.26",ModbusAddress=26,PointName="1E/87 (F35) OSCILLOGRAPHY TRIGGER COUNT @D20_1",OldValue=99999,PendingEvent=false}
tbl_GERelays[12] = {Name="F35-51-1A-B",IP="172.168.154.27",ModbusAddress=27,PointName="1E/51 (F35) 1A OSCILLOGRAPHY TRIGGER COUNT @D20_1",OldValue=99999,PendingEvent=false}
tbl_GERelays[13] = {Name="T60-T1-B",IP="172.168.154.28",ModbusAddress=28,PointName="T1/(T60) OSCILLOGRAPHY TRIGGER COUNT @D20_1",OldValue=99999,PendingEvent=false}
tbl_GERelays[14] = {Name="F60-T1-B",IP="172.168.154.29",ModbusAddress=29,PointName="T1/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_1",OldValue=99999,PendingEvent=false}
tbl_GERelays[15] = {Name="F60-24B-B",IP="172.168.154.30",ModbusAddress=30,PointName="24B/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_2",OldValue=99999,PendingEvent=false}
tbl_GERelays[16] = {Name="F60-23B-B",IP="172.168.154.31",ModbusAddress=31,PointName="23B/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_2",OldValue=99999,PendingEvent=false}
tbl_GERelays[17] = {Name="F60-22B-B",IP="172.168.154.32",ModbusAddress=32,PointName="22B/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_2",OldValue=99999,PendingEvent=false}
tbl_GERelays[18] = {Name="F60-21B-B",IP="172.168.154.33",ModbusAddress=33,PointName="21B/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_2",OldValue=99999,PendingEvent=false}
tbl_GERelays[19] = {Name="F35-87-2B-B",IP="172.168.154.34",ModbusAddress=34,PointName="31A/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_3",OldValue=99999,PendingEvent=false}
tbl_GERelays[20] = {Name="F35-51-2B-B",IP="172.168.154.35",ModbusAddress=35,PointName="2W/51 (F35) OSCILLOGRAPHY TRIGGER COUNT @D20_2",OldValue=99999,PendingEvent=false}
tbl_GERelays[21] = {Name="F60-24A-B",IP="172.168.154.36",ModbusAddress=36,PointName="24A/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_2",OldValue=99999,PendingEvent=false}
tbl_GERelays[22] = {Name="F60-23A-B",IP="172.168.154.37",ModbusAddress=37,PointName="23A/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_2",OldValue=99999,PendingEvent=false}
tbl_GERelays[23] = {Name="F60-22A-B",IP="172.168.154.38",ModbusAddress=38,PointName="22A/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_2",OldValue=99999,PendingEvent=false}
tbl_GERelays[24] = {Name="F60-21A-B",IP="172.168.154.39",ModbusAddress=39,PointName="21A/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_2",OldValue=99999,PendingEvent=false}
tbl_GERelays[25] = {Name="F35-87-2A-B",IP="172.168.154.40",ModbusAddress=40,PointName="2E/87 (F35) OSCILLOGRAPHY TRIGGER COUNT @D20_2",OldValue=99999,PendingEvent=false}
tbl_GERelays[26] = {Name="F35-51-2A-B",IP="172.168.154.41",ModbusAddress=41,PointName="2E/51 (F35) 1A OSCILLOGRAPHY TRIGGER COUNT @D20_2",OldValue=99999,PendingEvent=false}
tbl_GERelays[27] = {Name="T60-T2-B",IP="172.168.154.42",ModbusAddress=42,PointName="T2/(T60) OSCILLOGRAPHY TRIGGER COUNT @D20_2",OldValue=99999,PendingEvent=false}
tbl_GERelays[28] = {Name="F60-T2-B",IP="172.168.154.43",ModbusAddress=43,PointName="T2/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_2",OldValue=99999,PendingEvent=false}
tbl_GERelays[29] = {Name="F60-34B-B",IP="172.168.154.44",ModbusAddress=44,PointName="34B/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_3",OldValue=99999,PendingEvent=false}
tbl_GERelays[30] = {Name="F60-33B-B",IP="172.168.154.45",ModbusAddress=45,PointName="33B/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_3",OldValue=99999,PendingEvent=false}
tbl_GERelays[31] = {Name="F60-32B-B",IP="172.168.154.46",ModbusAddress=46,PointName="32B/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_3",OldValue=99999,PendingEvent=false}
tbl_GERelays[32] = {Name="F60-31B-B",IP="172.168.154.47",ModbusAddress=47,PointName="31B/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_3",OldValue=99999,PendingEvent=false}
tbl_GERelays[33] = {Name="F35-87-3B-B",IP="172.168.154.48",ModbusAddress=48,PointName="3W/87 (F35) OSCILLOGRAPHY TRIGGER COUNT @D20_3",OldValue=99999,PendingEvent=false}
tbl_GERelays[34] = {Name="F35-51-3B-B",IP="172.168.154.49",ModbusAddress=49,PointName="3W/51 (F35) OSCILLOGRAPHY TRIGGER COUNT @D20_3",OldValue=99999,PendingEvent=false}
tbl_GERelays[35] = {Name="F60-34A-B",IP="172.168.154.50",ModbusAddress=50,PointName="34A/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_3",OldValue=99999,PendingEvent=false}
tbl_GERelays[36] = {Name="F60-33A-B",IP="172.168.154.51",ModbusAddress=51,PointName="33A/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_3",OldValue=99999,PendingEvent=false}
tbl_GERelays[37] = {Name="F60-32A-B",IP="172.168.154.52",ModbusAddress=52,PointName="32A/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_3",OldValue=99999,PendingEvent=false}
tbl_GERelays[38] = {Name="F60-31A-B",IP="172.168.154.53",ModbusAddress=53,PointName="31A/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_3",OldValue=99999,PendingEvent=false}
tbl_GERelays[39] = {Name="F35-87-3A-B",IP="172.168.154.54",ModbusAddress=54,PointName="3E/87 (F35) OSCILLOGRAPHY TRIGGER COUNT @D20_3",OldValue=99999,PendingEvent=false}
tbl_GERelays[40] = {Name="F35-51-3A-B",IP="172.168.154.55",ModbusAddress=55,PointName="3E/51 (F35) 1A OSCILLOGRAPHY TRIGGER COUNT @D20_3",OldValue=99999,PendingEvent=false}
tbl_GERelays[41] = {Name="T60-T3-B",IP="172.168.154.56",ModbusAddress=56,PointName="T3/(T60) OSCILLOGRAPHY TRIGGER COUNT @D20_3",OldValue=99999,PendingEvent=false}
tbl_GERelays[42] = {Name="F60-T3-B",IP="172.168.154.57",ModbusAddress=57,PointName="T3/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_3",OldValue=99999,PendingEvent=false}
tbl_GERelays[43] = {Name="F60-44B-B",IP="172.168.154.58",ModbusAddress=58,PointName="44B/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_4",OldValue=99999,PendingEvent=false}
tbl_GERelays[44] = {Name="F60-43B-B",IP="172.168.154.59",ModbusAddress=59,PointName="43B/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_4",OldValue=99999,PendingEvent=false}
tbl_GERelays[45] = {Name="F60-42B-B",IP="172.168.154.60",ModbusAddress=60,PointName="42B/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_4",OldValue=99999,PendingEvent=false}
tbl_GERelays[46] = {Name="F60-41B-B",IP="172.168.154.61",ModbusAddress=61,PointName="41B/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_4",OldValue=99999,PendingEvent=false}
tbl_GERelays[47] = {Name="F35-87-4B-B",IP="172.168.154.62",ModbusAddress=62,PointName="4W/87 (F35) OSCILLOGRAPHY TRIGGER COUNT @D20_4",OldValue=99999,PendingEvent=false}
tbl_GERelays[48] = {Name="F35-51-4B-B",IP="172.168.154.63",ModbusAddress=63,PointName="4W/51 (F35) OSCILLOGRAPHY TRIGGER COUNT @D20_4",OldValue=99999,PendingEvent=false}
tbl_GERelays[49] = {Name="F60-44A-B",IP="172.168.154.64",ModbusAddress=64,PointName="44A/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_4",OldValue=99999,PendingEvent=false}
tbl_GERelays[50] = {Name="F60-43A-B",IP="172.168.154.65",ModbusAddress=65,PointName="43A/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_4",OldValue=99999,PendingEvent=false}
tbl_GERelays[51] = {Name="F60-42A-B",IP="172.168.154.66",ModbusAddress=66,PointName="42A/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_4",OldValue=99999,PendingEvent=false}
tbl_GERelays[52] = {Name="F60-41A-B",IP="172.168.154.67",ModbusAddress=67,PointName="41A/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_4",OldValue=99999,PendingEvent=false}
tbl_GERelays[53] = {Name="F35-87-4A-B",IP="172.168.154.68",ModbusAddress=68,PointName="4E/87 (F35) OSCILLOGRAPHY TRIGGER COUNT @D20_4",OldValue=99999,PendingEvent=false}
tbl_GERelays[54] = {Name="F35-51-4A-B",IP="172.168.154.69",ModbusAddress=69,PointName="4E/51 (F35) 1A OSCILLOGRAPHY TRIGGER COUNT @D20_4",OldValue=99999,PendingEvent=false}
tbl_GERelays[55] = {Name="T60-T4-B",IP="172.168.154.70",ModbusAddress=70,PointName="T4/(T60) OSCILLOGRAPHY TRIGGER COUNT @D20_4",OldValue=99999,PendingEvent=false}
tbl_GERelays[56] = {Name="F60-T4-B",IP="172.168.154.71",ModbusAddress=71,PointName="T4/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_4",OldValue=99999,PendingEvent=false}
tbl_GERelays[57] = {Name="F60-C1-B",IP="172.168.154.72",ModbusAddress=72,PointName="C1/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_5",OldValue=99999,PendingEvent=false}
tbl_GERelays[58] = {Name="F60-C2-B",IP="172.168.154.73",ModbusAddress=73,PointName="C2/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_5",OldValue=99999,PendingEvent=false}
tbl_GERelays[59] = {Name="T60-T5-B",IP="172.168.154.74",ModbusAddress=74,PointName="T5/(T60) OSCILLOGRAPHY TRIGGER COUNT @D20_5",OldValue=99999,PendingEvent=false}
tbl_GERelays[60] = {Name="F60-T5-B",IP="172.168.154.75",ModbusAddress=75,PointName="T5/(F60) OSCILLOGRAPHY TRIGGER COUNT @D20_5",OldValue=99999,PendingEvent=false}
tbl_GERelays[61] = {Name="F35-87-SYA-B",IP="172.168.154.76",ModbusAddress=76,PointName="87-SYA (F35) OSCILLOGRAPHY TRIGGER COUNT @D20_5",OldValue=99999,PendingEvent=false}
tbl_GERelays[62] = {Name="F35-51-SYA-B",IP="172.168.154.77",ModbusAddress=77,PointName="51-SYA (F35) OSCILLOGRAPHY TRIGGER COUNT @D20_5",OldValue=99999,PendingEvent=false}
tbl_GERelays[63] = {Name="F35-87-SYB-B",IP="172.168.154.78",ModbusAddress=78,PointName="87-SYB (F35) OSCILLOGRAPHY TRIGGER COUNT @D20_5",OldValue=99999,PendingEvent=false}
tbl_GERelays[64] = {Name="F35-51-SYB-B",IP="172.168.154.79",ModbusAddress=79,PointName="51-SYB (F35) OSCILLOGRAPHY TRIGGER COUNT @D20_5",OldValue=99999,PendingEvent=false}



-- Global Variables For All Subroutines
str = {} -- Global Holder For NCD Contents to manipulate
Zone_Alarm_Table = {}  -- Built automatically on restart by reading the AAR in the active NCD file
Zone_List = {}	-- Built coincident with the Zone_Alarm_Table
Category_Table = {}
Category_Table[1] ={"T_2","T_3","T_11","T_12","T_13","T_14"}
Category_Table[2] ={"T_21","T_22","T_23","T_24"}
Category_Table[3] ={"T_1"}
Category_Table[4] ={"T_6","T_8","T_10","T_16","T_17","T_18","T_19",
				"T_21","T_22","T_23","T_24","T_26","T_27","T_28","T_29",
				"T_31","T_32","T_33","T_34","T_35","T_36","T_37","T_38","T_39",
				"T_41","T_42","T_43","T_44","T_45","T_46","T_47","T_48","T_49",
				"T_51","T_52","T_53","T_55","T_57","T_58","T_59",
				"T_61","T_63","T_68","T_69","T_70"}

LR_Mismatch_Table = {
	BS_1E = {D20="D25_1";Breakers={"11A","12A","13A","14A","1SYA","1TA"}};
	BS_2E = {D20="D25_2";Breakers={"21A","22A","23A","24A","2SYA","2TA"}};
	BS_3E = {D20="D25_3";Breakers={"31A","32A","33A","34A","3SYA","3TA"}};
	BS_4E = {D20="D25_4";Breakers={"41A","42A","43A","44A","4SYA","4TA"}};
	BS_5E = {D20="D25_5";Breakers={"C1","5SYA"}};
	BS_1W = {D20="D20_1";Breakers={"11B","12B","13B","14B(C3)","1SYB","1TB","CI-1","CS-1","T1_TC"}};
	BS_2W = {D20="D20_2";Breakers={"21B","22B","23B","24B","2SYB","2TB","CI-2","CS-2","T2_TC"}};
	BS_3W = {D20="D20_3";Breakers={"31B","32B","33B","34B","3SYB","3TB","CI-3","CS-3","T3_TC"}};
	BS_4W = {D20="D20_4";Breakers={"41B","42B","43B","44B","4SYB","4TB","CI-4","CS-4","T4_TC"}};
	BS_5W = {D20="D20_5";Breakers={"C2","C1A","C1B","C2","C2A","C2B","5SYB"}};
	}

Breaker_Tags_List ={"PORTABLE_GROUNDS","IATC","HVTC","CATC","ALIVE_ON_BACKFEED",
		"TEST_POSITION","LINKS_REMOVED_GROUNDBAR","LINE_IN_SHORT",
		"LVFFTC","WORK_PERMIT","RACKED_OUT"}
		
CS_Tags_List ={"BUSHING_GROUNDS","PRI_PT_FUSES_REMOVED","SEC_PT_FUSES_REMOVED",
		"DELUGE_REMOVED","FEED_REMOVED_FROM_CMVM","C/S_BLOCKED_OPEN",
		"WORK_PERMIT","CMVM_IN_INDIVIDUAL",	"PORTABLE_GROUNDS"}

--########################################################################################################################
--# V0 6/25/2013																											#
--# get_ncd_active_filename() -  This subroutine opens the file orion16.ini and determines the active filename executing in the OrionLX			#
--########################################################################################################################
function NCD_File_get_active_filename()
    local mf = io.open("/etc/orion/orion16.ini") -- read ini file indicating contents
    if mf then  -- Orion16.ini found
        local str -- Create A Holder For The Input File
        str = mf:read( "*all" ) -- Read The Input File into the string attribute.
        local start_str,end_str
        start_str, end_str = string.find(str,"ActiveConfig = ") -- keyword for executing file in NCD

        if ((start_str ~= nil) and (end_str ~= nil)) == false then
            orion.PrintLog("Core Error - Internal File Error") -- Orion16.ini file corruption
            start_str = 0; end_str = 0 -- set variables to display additional errors in OrionLX 
        end

        local file_str_start, file_str_end
        file_str_start, file_str_end = string.find(str,".ncd", end_str+1)

        if ((file_str_start ~= nil) and (file_str_end ~= nil)) == true then
            active_config = string.sub(str, end_str+1,file_str_start -1) ..".ncd" -- Active Configuration File Name
            orion.PrintLog("Active NCD File: " .. active_config)
        else
            orion.PrintLog("CoreError: No Active Configuration")
        end
        mf:close()
    else
        orion.PrintLog("CoreError: No Active Configuration")
    end
end


function NCD_File_build_Zone_Alarm_Table()
    --############	TASK 1 - Open The File and Read Contents Into The Array Container ###################################################################
    local Active_NCD_File = "/etc/orion/" .. active_config
    local inpf = io.open(Active_NCD_File) -- open lua file to determine if it exists

    if inpf then
        inpf = io.open(Active_NCD_File, "r") -- read in lua file
        str = inpf:read( "*all" ) -- Read The Input File
        inpf:close() -- close the actively running input file 
        orion.PrintLog("NCD Filename " .. Active_NCD_File .. " Found") -- ACTIVE NCD FILE IS FOUND - Read In The Active Configuration Data

        local start_pos
        local end_pos        
        local start_pos_new
        local end_pos_new
        local line = {}
        local index_count = 0
        local zone_count = 0
        local Archive_count = 0
        local Alarm_count = 0
        local char1, comma
        local hashtag = "#"
    
-- find the first line of the AAR configuration;  which ends with "OffCode,OffMessage\r\n"
    	start_pos,end_pos = string.find(str,"OffCode,OffMessage\r\n")
        
--  Read each line of the AAR while the line is not empty 
	orion.PrintLog("Build Table:  Zone_Alarm_Table")
       	    while start_pos ~= nil and line ~= "\r\n" do
	        	start_pos_new,end_pos_new = string.find(str, "\r\n", end_pos+1)
	        	-- read the next line starting with the 1st character after the line return and ending with the next line return.
   	    		line = string.sub(str, end_pos+1, end_pos_new)
   	    		-- parse the line to find each field
   	    		comma = string.find(line,",",1)
   	    		char1 = orion.Left(line,1)
   	    		
   	    		if comma ~= nil  then
   	    		--	index_count = index_count+1    			
	   	    		local PointName = string.sub(line,1,comma-1)
	   	    		local field_pos = comma+1
	   	    		
	   	    		char1 = string.sub(PointName,1,1)
	   	    		if char1 ~= hashtag then
		   	    	 	comma = string.find(line,",",field_pos)
		   	    		local MinVal = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)
		   	    		local MaxVal = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)
		   	    		local ArchiveEnable = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)
		   	    		local ArchiveDeadBand = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)
		   	    		local ArchiveInterval = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)
		   	    		local ArchiveType = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)
		   	    		local InitialValue = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)
		   	    		local Zone = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)
		   	    		local RetentiveEnable = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)
		   	    		local RetentiveDeadBand = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)	
		   	    		local AlarmEnable = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)	
		   	    		local AlarmGroup = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)	
		   	    		local NormalState = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)	
		   	    		local NormalCode = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)	
		   	    		local ReturnToNormalMessage = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)	
		   	    		local LoLoEnable = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)	
		   	    		local LoLoLevel = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)	
		   	    		local LoLoCode = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)	
		   	    		local LoLoMessage = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)	
		   	    		local LoEnable = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)	
		   	    		local LoLevel = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)	
		   	    		local LoCode = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)	
		   	    		local LoMessage = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)	
		   	    		local HiEnable = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)	
		   	    		local HiLevel = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)	
		   	    		local HiCode = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)	
		   	    		local HiMessage = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)	
		   	    		local HiHiEnable = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)	
		   	    		local HiHiLevel = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)	
		   	    		local HiHiCode = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)	
		   	    		local HiHiMessage = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)	
		   	    		local OnEnable = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)	
		   	    		local OnCode = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)	
		   	    		local OnMessage = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)	
		   	    		local OffEnable = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		comma = string.find(line,",",field_pos)	
		   	    		local OffCode = string.sub(line,field_pos,comma-1)
		   	    		field_pos = comma+1
		   	    		
		   	    		local OffMessage = string.sub(line,field_pos,end_pos)
		   	    				   	    		
		   	 		   	    		
			   	    	if AlarmEnable == "1" then	-- Only process points where AlarmEnable = 1
  		 	    			index_count = index_count+1    	
			   	    		Alarm_count = Alarm_count + 1
			       		--	orion.PrintLog(PointName.." is in zone "..Zone)
		     	  		--	orion.PrintLog(index_count..": T_"..Zone..","..PointName)
		       				table.insert(Zone_Alarm_Table,index_count,{})		
						table.insert(Zone_Alarm_Table[index_count],1,"T_"..Zone)
						table.insert(Zone_Alarm_Table[index_count],2,PointName)
						table.insert(Zone_Alarm_Table[index_count],3,NormalState)
			       		--	orion.PrintLog(index_count..": "..Zone_Alarm_Table[index_count][1]..","..Zone_Alarm_Table[index_count][2])
		   	    			
		   	    			local found_zone = 0
		   	    			local find_zone = Zone_Alarm_Table[index_count][1]
		   	    			for i in pairs(Zone_List) do  -- reset alarm counts
						--	zone_count = i
							if find_zone == Zone_List[i] then
								found_zone = 1
								break
							end
		   	    			end
		   	    			
		   	    			if found_zone  == 0 then
							zone_count=zone_count+1							
							Zone_List[zone_count]=find_zone
						--	orion.PrintLog("Add zone "..zone_count..": "..Zone_List[zone_count])
		   	    			end	
		   	    		else
		   	    			Archive_count = Archive_count+1	
			   	    	end	-- end processing AlarmEnable == 1
	   	    		end		
	   	    		end_pos = end_pos_new -- advance to the next line
	   	    		start_pos = start_pos_new -- advance to the next line
	   	    	else	-- end of AAR file read
	   	    		index_count = index_count-1
	   	    		orion.PrintLog("Zone_Alarm_Table contains "..index_count.." points and "..zone_count.." zones")    -- verifies success	   	    	
	   	    		orion.PrintLog("Alarmed points: "..Alarm_count.."  Archived points: "..Archive_count) 
	   	    		break
   	    		end		
       	    end       	    
    end    
end


function NCD_File_put_pseudo_points_online()
	    --############	TASK 1 - Open The File and Read Contents Into The Array Container ###################################################################
	local Active_NCD_File = "/etc/orion/" .. active_config
    	local inpf = io.open(Active_NCD_File) -- open lua file to determine if it exists
	local start_pos,  end_pos, start_pos_new, end_pos_new, field_pos
	local PortName, start_name, end_name
	local line = {}
	local comma, char1
	local found = 1
	local count = 0
	local PointName, device, device_type
	
    if inpf then
        inpf = io.open(Active_NCD_File, "r") -- read in lua file
        str = inpf:read( "*all" ) -- Read The Input File
        inpf:close() -- close the actively running input file 
 --       orion.PrintLog("NCD Filename " .. Active_NCD_File .. " Found") -- ACTIVE NCD FILE IS FOUND - Read In The Active Configuration Data

   	end_pos = 0
	-- find the first line of the port using pseudo master protocol
	    	start_pos,end_pos = string.find(str,"ModuleName=mpsdo\r\n",end_pos+1)
		-- find the port name
		    	start_pos,end_pos = string.find(str,"PortName=",end_pos+1)
		    	start_name=end_pos+1
		    	start_pos,end_pos = string.find(str,"\r\n",end_pos+1)
   			end_name = start_pos-1
   			PortName =string.sub(str, start_name, end_name)
   			
	while found >= 1 do
	    	if start_pos~=nil and end_pos~=nil then
		-- find the start of the Inputs
		    	start_pos,end_pos = string.find(str,"Inputs]\r\n",end_pos+1)
	    		line = "Pseudo Master Port Inputs"
	    		
		--  Read each line of the Inputs while the line is not empty 
			while start_pos ~= nil and line ~= "\r\n" do
				start_pos_new,end_pos_new = string.find(str, "\r\n", end_pos+1)
				-- read the next line starting with the 1st character after the line return and ending with the next line return.
				line = string.sub(str, end_pos+1, end_pos_new)
		   	    	char1 = orion.Left(line,1)  -- test for a space or the beginnning of the Outputs block
		
		 		comma = string.find(line,",",1) 	-- check for a blank line 
		 		   	
		   	    	if comma ~= nil and char1 ~= "[" and char1 ~= " " then   	    	
					-- parse the line to find each field  	   	    		 			
					PointName = string.sub(line,1,comma-1)
					field_pos = comma+1
				    		
					comma = string.find(line,",",field_pos)
					device = string.sub(line,field_pos,comma-1)
					field_pos = comma+1
			   	    		
					comma = string.find(line,",",field_pos)
					device_type = string.sub(line,field_pos,comma-1)
			   	    		
					if device_type ~= "Comm Fail" and device_type ~= "Polls" and device_type ~= "Responses" then
						orion.SetPoint({name=PointName, online=true})  -- put the point ONLINE without changing the value
						count = count+1
					end	 
				else
					break	
		   	    	end	
				end_pos = end_pos_new -- advance to the next line
				start_pos = start_pos_new -- advance to the next line
			end -- do while still reading pseudo master port
			
			orion.PrintLog(PortName..":  "..count.." pseudo points ONLINE.")     -- verifies success
			count = 0
				
			-- find the first line of the NEXT pseudo master port
		    	start_pos,end_pos = string.find(str,"ModuleName=mpsdo\r\n",end_pos_new+1)
		    	-- find the port name
		    	if start_pos~=nil and end_pos~=nil then
			    	start_pos,end_pos = string.find(str,"PortName=",end_pos+1)
			    	start_name=end_pos+1
			    	start_pos,end_pos = string.find(str,"\r\n",end_pos+1)
	   			end_name = start_pos-1
	   			PortName =string.sub(str, start_name, end_name)
	   			found = found+1
	   		else
	   			found = 0	
		    	end	
	    	else
		    	found = 0 -- no more pseudo master ports are found
	    	end	-- if start_pos~=nil
	    end-- do while found=1		
    end      
end


function Annunciator_Display_Timer()
	alarmpt = {}
	tile_info = {}
	local tile, point, inverted
	local zone_count, zone
	local alarm_active, alarm_unk, alarm_value, alarm_online, alarm_count
	local total_unk = 0
	local total_alarms = 0
	local tile_logicpt, zone_idx, zone_text, zone_online
	
	local status ={}
	status = orion.GetPoint("CAT 1 STATION FIRE @Annunciator")
	local cat1_status = status.value
	if cat1_status == nil then cat1_status = 0 end
	local cat1_flag = 0
	status = orion.GetPoint("CAT 2 LOSS OF DC @Annunciator")
	local cat2_status = status.value
	if cat2_status == nil then cat2_status = 0 end
	local cat2_flag = 0
	status = orion.GetPoint("CAT 3 STATION ACCESS @Annunciator")
	local cat3_status = status.value	
	if cat3_status == nil then cat3_status = 0 end
	local cat3_flag = 0
	status = orion.GetPoint("CAT 4 STATION TROUBLE @Annunciator")
	local cat4_status = status.value
	if cat4_status == nil then cat4_status = 0 end
	local cat4_flag = 0
	
	
	for i in pairs(Zone_List) do  -- reset alarm counts
		table.insert(tile_info,i,{})		
		table.insert(tile_info[i],1,Zone_List[i])	-- Tile name
		table.insert(tile_info[i],2,0)	--  number of points in alarm
		table.insert(tile_info[i],3,"online")	-- online status
		table.insert(tile_info[i],4,0)	-- number of points under tile
		table.insert(tile_info[i],5,0)	-- number of disabled points under tile
		zone_count = i
	end
		
	for j in pairs(Zone_Alarm_Table) do  -- count the number of active alarms in each zone
		tile = Zone_Alarm_Table[j][1]
		point = Zone_Alarm_Table[j][2]
		inverted = Zone_Alarm_Table[j][3]
		
	--	orion.PrintDiag(j..": "..tile.." "..point)
		tile_logicpt = tile.." @Annunciator"
		zone_idx = 0
		for find_zone in pairs(Zone_List) do  -- reset alarm counts
			if Zone_List[find_zone]	== tile then 
				zone_idx = find_zone
				break
			end
		end	
		if zone_idx == 0 then
		--	orion.PrintLog("Zone "..tile.. " not found in Zone_List")
			alarm_active = 0
			alarm_count = 0
		else
			alarm_active = tile_info[zone_idx][2]	-- get the alarm count for this zone so far
			alarm_count = tile_info[zone_idx][4]	
			total_alarms = total_alarms+alarm_count
			
			alarmpt = orion.GetPoint(point)
			alarm_value = alarmpt.value
			alarm_online = alarmpt.online
		--	orion.PrintDiag(j..": "..point.." = "..alarm_value)
		
			if inverted == "1" then
				alarm_value = (alarm_value * (-1)) +1
			end	
			
			if alarm_value == 1 then  -- count the number of active alarms
				tile_info[zone_idx][2] = alarm_active+1
				-- orion.PrintDiag(j..": "..point.." is in alarm state: "..alarm_value)
				-- orion.PrintDiag(tile.." = "..alarm_active
				-- set the associated Category alarm				
			end
			
			if alarm_online == 0 then  -- if any point is offline then the logic point is offline
				tile_info[zone_idx][3] = "offline"
			end
			
			tile_info[zone_idx][4] = alarm_count+1	-- count the number of alarm points in this tile		
		end	
	end	
	
	local trouble = 0
	alarm_active = 0
	alarm_count = 0
	total_unk = 0

	for k = 1, 94 do  -- blink the zone tile if there are unacknowledged alarms in the zone
		zone_text = "T_"..k
		tile_logicpt = zone_text.." @Annunciator"
		local found_zone = 0
		
		for find_zone in pairs(tile_info) do  --find the table index for this zone
			if tile_info[find_zone][1] == zone_text then 
				zone_idx = find_zone
				found_zone = 1
				break
			end
		end	
		if found_zone == 0 then
			alarm_active = 0  -- get the number of active alarms
			zone_online = "online" -- get the online status (only stored as a string at this time)
		else	
			alarm_active = tile_info[zone_idx][2]  -- get the number of active alarms
			zone_online = tile_info[zone_idx][3] -- get the online status (only stored as a string at this time)
			alarm_count = tile_info[zone_idx][4] -- get the online status (only stored as a string at this time)
				
			if alarm_active ~=  0 then	--  Flag the alarm category if there are any active alarms
				for cat1 in pairs (Category_Table[1]) do
					if zone_text == Category_Table[1][cat1] then
						cat1_flag = 1						
					--	orion.PrintDiag("Tile "..zone_text.." in cat 1 has active alarms")
					end	
				end	
				for cat2 in pairs (Category_Table[2]) do
					if zone_text == Category_Table[2][cat2] then
						cat2_flag = 1						
					--	orion.PrintDiag("Tile "..zone_text.." in cat 2 has  active alarms")
					end	
				end	
				for cat3 in pairs (Category_Table[3]) do
					if zone_text == Category_Table[3][cat3] then
						cat3_flag = 1						
					--	orion.PrintDiag("Tile "..zone_text.." in cat 3 has active alarms")
					end	
				end	
				for cat4 in pairs (Category_Table[4]) do
					if zone_text == Category_Table[4][cat4] then	
						cat4_flag = 1						
					--	orion.PrintDiag("Tile "..zone_text.." in cat 4 has active alarms")
					end	
				end	
			end
		end	
	
--  	check if there are ANY unacknowledged alarms in the project
		alarm_unk = 0
		if k < 91 then -- only blink annunciator tiles 1 to 90
			alarm_unk=orion.GetUnacknowledgedAlarmCount(k,true) -- check if ANY alarms are unacknowledged
			total_unk = total_unk+alarm_unk
			if alarm_unk > 0 then
					alarm_active  = -1 * alarm_active   -- blink the annunciator for values <= 0, do not blink when  > 0
					-- orion.PrintDiag("BLINK:  "..zone_text..", active ="..alarm_active..", unkacknowledged ="..alarm_unk)
					trouble = 2	-- blink the STATION TROUBLE ALARM tile for any unacknowledged alarm
					-- orion.PrintDiag(trouble..": Setting ALARM Tile for unacknowledged alarms")
					
			elseif alarm_active   == 0 then  -- hide the alarm tile
					alarm_active   = 9999	-- exception no active alarms and no unacknowledged
				--	orion.PrintDiag("HIDE: "..zone_text)
			end	
			if alarm_active ~= 9999 then
				-- orion.PrintDiag("Alarms in zone: "..zone_text.." = "..alarm_active )
				if trouble < 2 then
					trouble = 1	-- display the STATION TROUBLE ALARM tile as RED if there is an active alarm and all alarms are acknowledged
					-- orion.PrintDiag(trouble..": Setting ALARM Tile for active alarms")
				end	
			end
		end	
		orion.SetPoint({name=tile_logicpt, value=alarm_active , string=zone_online, online=true}) -- update the tile information
	end	
		-- Set the Category Alarms
	if cat1_status ~= cat1_flag then
		orion.SetPoint({name = "CAT 1 STATION FIRE @Annunciator", value = cat1_flag, online=true})
		orion.PrintDiag("CAT1 status change "..cat1_status.." to "..cat1_flag)
	end	
	if cat2_status ~= cat2_flag then
		orion.SetPoint({name = "CAT 2 LOSS OF DC @Annunciator", value = cat2_flag, online=true})
		orion.PrintDiag("CAT2 status change "..cat2_status.." to "..cat2_flag)
	end	
	if cat3_status ~= cat3_flag then
		orion.SetPoint({name = "CAT 3 STATION ACCESS @Annunciator", value = cat3_flag, online=true})
		orion.PrintDiag("CAT3 status change "..cat3_status.." to "..cat3_flag)
	end	
	if cat4_status ~= cat4_flag then
		orion.SetPoint({name = "CAT 4 STATION TROUBLE @Annunciator", value = cat4_flag, online=true})		
		orion.PrintDiag("CAT4 status change "..cat4_status.." to "..cat4_flag)
	end	
	-- orion.PrintDiag("STATION TROUBLE = "..trouble)
	orion.SetPoint({name =	"STATION_TROUBLE @Logic", value=trouble, online=true})
		
-- Find all blocked alarms and set the BLOCKED indicators in the annunciator
	local PrintString
	local disabled
	
	--create environment object of pgdb
	local env = assert (luasql.postgres())
   
	--connect to data source
	local con = assert (env:connect("dbname=postgres host=/var/run/postgresql user=retentive"))
	
	--create cursor for stepping through results
	local QueryString = 'SELECT * FROM "points_blocking";'

	local cur = assert (con:execute(QueryString))

	PrintString =""

	local row = cur:fetch({}, "a")
	
	if row then
		while row do			
			local pointname = (row.point_name)
			local blocked_state = (row.blocked_state) -- 0=not blocked, 1 blocked.  Points aren't written to database until they are blocked once.
				
			PrintString = pointname .. "  " .. blocked_state	
		--	orion.PrintDiag(PrintString)
			
			for find_alarm in pairs(Zone_Alarm_Table) do -- search the alarm list to match the alarm point name
				point = Zone_Alarm_Table[find_alarm][2]
				if point == pointname then 
					local tile_name =  Zone_Alarm_Table[find_alarm][1]
					for tile_idx in pairs(tile_info) do
						if tile_name == tile_info[tile_idx][1] then
							if blocked_state == "1" then
								disabled = tile_info[tile_idx][5] 
								tile_info[tile_idx][5] = disabled + 1
							end
							break
						end
					end
				--	orion.PrintDiag("   BREAK find_alarm")
					break
				end
			end				
			row = cur:fetch(row, "a") --get next row of query result
		end				
	end
	
	cur:close()
	con:close()
	env:close()	
	-- orion.PrintDiag("Check for blocking: "..zone_count)
	
	for blocked = 1, zone_count do
		local disable_tile = tile_info[blocked][1]
		local disable_logicpt = disable_tile.." @Disabled"
		alarm_count = tile_info[blocked][4]
		disabled = tile_info[blocked][5] 
		-- orion.PrintLog(disable_tile.." = "..disabled)
		if disabled == 0 then	
			orion.SetPoint({name=disable_logicpt, value=0, online=true}) -- update the disabled information
		elseif disabled == alarm_count then
			orion.SetPoint({name=disable_logicpt, value=1, online=true}) -- update the disabled information
		--	orion.PrintDiag(disable_tile.." is fully disabled")
		else	
			orion.SetPoint({name=disable_logicpt, value=-1, online=true}) -- update the disabled information
		--	orion.PrintDiag(disable_tile.." is semi-disabled")
		end
	end	 		
end	


function Grounds_and_Links(PointName)
--	This will toggle the value of the corresponding mimic switch whenever the control point is refreshed.
--	The value of the control point is irrelevant, only the name of the point is used in this logic
	orion.PrintDiag("Grounds_and_Links: "..PointName)
	
	local point_name  = PointName	-- "11A/GND CNTL @X_BUS1"
	local at         = string.find(point_name," @X_")
	local length	= string.len(point_name)
	local device       = orion.Right(point_name,length-at)
	local cntl        = string.find(point_name," CNTL")
	local point       = orion.Left(point_name,cntl-1)
	
	local toggle    = point.." "..device
	local status      = orion.GetPoint(toggle).value

	orion.PrintDiag("Toggle: "..toggle.." = "..status)
	
	local new_state = (status*(-1))+1
	orion.SetPoint({name=toggle, value=new_state, online=true})
		
	if new_state == 1 then
		orion.PrintDiag("Toggle "..toggle.." ON")
	else
		orion.PrintDiag("Toggle "..toggle.." OFF")
	end	
end

function ENABLE_TAGS()  -- this function will enable the breaker tagging by showing the TAG CNTL boxes
	local enable
	local command ={}
	
	command = orion.GetPoint("INSTALL CNTL @TAGS")
	enable =command.value
	if enable == 1 then
		orion.SetPoint({name="INSTALL @TAGS", value=1, online=true})
	 else
		orion.SetPoint({name="INSTALL @TAGS", value=0, online=true})	
	end	
end

function INSTALL_REMOVE_TAGS(PointName)
	orion.PrintDiag("INSTALL_REMOVE_TAGS("..PointName)
	local command ={}
	local CNTL = string.find(PointName," CNTL @")
	local point = orion.Left(PointName,CNTL)
	local at = string.find(PointName," @")
	local len = string.len(PointName)
	local BkrTag = orion.Right(PointName,len-at)
	local tag = point..BkrTag
	orion.PrintDiag("SetPoint:  "..tag)
	
	command = orion.GetPoint(PointName)
	local cmd = command.value
	
	if cmd == 1 then
		orion.SetPoint({name=tag, value=1, online=true})
		orion.PrintDiag("INSTALL: "..tag)
	 else
		orion.SetPoint({name=tag, value=0, online=true})	
		orion.PrintDiag("REMOVE: "..tag)
	end	
	Block_Breaker_Control(BkrTag)
	
end

function Block_Breaker_Control(BkrTag)
	local CS =orion.Mid(BkrTag,2,2)
	orion.PrintDiag("Block_Breaker_Control: "..BkrTag.." "..CS)
	
	local command ={}
	local underscore = string.find(BkrTag,"_TAG")
	local BKR = orion.Left(BkrTag,underscore-1)
	
	-- check if any tags are present	
	local tags_present = 0
	local TagName
	local tag ={}
	if CS == "CS" then 
		for i in pairs(CS_Tags_List) do			
			TagName = CS_Tags_List[i].." "..BkrTag
			orion.PrintDiag("Checking tagname: "..TagName)			
			tag = orion.GetPoint(TagName)
			local value = tag.value
			if value == 1 then
				tags_present = 1
				orion.PrintDiag("Active tag found: "..TagName)
				break
			end	
		end	
	else
		for j in pairs(Breaker_Tags_List) do			
			TagName = Breaker_Tags_List[j].." "..BkrTag
			orion.PrintDiag("Checking tagname: "..TagName)			
			tag = orion.GetPoint(TagName)
			local value = tag.value
			if value == 1 then
				tags_present = 1
				orion.PrintDiag("Active tag found: "..TagName)
				break
			end	
		end
	end
	
	TagName = "TAGS_PRESENT "..BkrTag
	orion.SetPoint({name=TagName, value=tags_present, online=true})
	orion.PrintDiag(TagName.." :"..tags_present)
	
	-- continue to check for other conditions that will block the breaker control
end

function TAGS_Countdown() -- automatically shut off the INSTALL TAGS after 1 minute
	local display = {}
	display = orion.GetPoint("INSTALL @TAGS")
	local start = display.value
	if start == 1 then
		orion.EnableTimer("TAGS") 
		orion.PrintDiag("INSTALL TAGS will be disabled in 1 minute")
	else
		orion.SetPoint({name="INSTALL @TAGS", value=0, online=true})
		orion.PrintDiag("INSTALL TAGS has been disabled.")
		orion.DisableTimer("TAGS")  -- disable this timer
	end
end

function TAGS_Timer()
	orion.SetPoint({name="INSTALL @TAGS", value=0, online=true})
	orion.DisableTimer("TAGS")  -- disable this timer
end

function METERING_TAB()
	orion.SetPoint({name="RELAY_TAB @Logic", value=0, online=true})
	orion.PrintDiag("METERING")
end

function TARGET_TAB()	
	orion.SetPoint({name="RELAY_TAB @Logic", value=1, online=true})
	orion.PrintDiag("TARGET")
end

function IO_TAB()
	orion.SetPoint({name="RELAY_TAB @Logic", value=2, online=true})
	orion.PrintDiag("I/O")
end

function LED_AND_ERRORS_TAB()
	orion.SetPoint({name="RELAY_TAB @Logic", value=3, online=true})
	orion.PrintDiag("LED & ERRORS")
end

function X_BUS_LR(PointName)
	local logic_val = 0
	local text_str = "LOCAL"
	
	local slash = string.find(PointName,"/")
	local point = orion.Left(PointName,slash)
	local at = string.find(PointName,"@")
	local len = string.len(PointName)
	local D20 = orion.Right(PointName,len-at)
	local bus = orion.Right(PointName,1)	
	local group = orion.Left(PointName,2)
	local first = orion.Left(PointName,1)
	
	local scada_pt = point.."SCADA LOCAL/REMOTE @"..D20
	local device_pt = point.."43-REM LOCAL/REMOTE @"..D20	
	if group =="CI" or group =="CS" then
		device_pt = point.."43-REM LOCAL/REMOTE AT "..group.." @"..D20	
	elseif first == "T" then
		device_pt = point.."43-REM LOCAL/REMOTE AT LTC @"..D20		
	end
	
	local scada={}
	local device={}
	scada = orion.GetPoint(scada_pt)
	device = orion.GetPoint(device_pt)
	local scada_val = scada.value
	local device_val = device.value	

	if scada_val ==1 and device_val == 1 then
		if group =="CI" or group =="CS" then
			local swg_pt = point.."43-REM LOCAL/REMOTE AT SWG @"..D20
			orion.PrintDiag(swg_pt)
			local swg = {}
			swg = orion.GetPoint(swg_pt)
			local swg_val = swg.value
			if swg_val == 1 then
				logic_val = 1
				text_str = "REMOTE"
			end
		elseif first == "T" then
			local panel_pt = point.."43-REM LOCAL/REMOTE AT PANEL @"..D20
			local panel = {}
			panel = orion.GetPoint(panel_pt)
			local panel_val = panel.value
			if panel_val == 1 then
				logic_val = 1
				text_str = "REMOTE"
			end
		else	
			logic_val = 1
			text_str = "REMOTE"
		end				
	end	
	
	local logic_pt = point.."LOCAL/REMOTE @X_BUS"..bus
	orion.SetPoint({name=logic_pt, value=logic_val, online=true})
	orion.PrintDiag(logic_pt.." = "..text_str)
	LR_MISMATCH()	-- Check for a SCADA BUS MISMATCH any time a local/remote point changes
end

function X_BUS_LR_CAP(PointName)
	local logic_val = 0
	local text

	local slash = string.find(PointName,"/")
	local point = orion.Left(PointName,slash-1)
	local bus = orion.Right(PointName,1)	
	
	local logic_pt
	local scada_pt
	local cap_pt 
	local swg_pt 
	
	local scada={}
	local cap={}
	local swg={}
	local scada_val
	local swg_val
	local cap_val
	
	if point == "C1" then
		scada=orion.GetPoint("C1/SCADA LOCAL/REMOTE @D25_5")
		swg=orion.GetPoint("C1/43-REM LOCAL/REMOTE @D25_5")
		cap =orion.GetPoint("1 @Logic")		
	elseif point == "C1A" then
		scada=orion.GetPoint("C1A/SCADA LOCAL/REMOTE @D20_5")
		swg=orion.GetPoint("1 @Logic")
	--	swg =orion.GetPoint("C1A/43-REM LOCAL/REMOTE AT SWG @D25_5")
		cap =orion.GetPoint("C1A/43-REM LOCAL/REMOTE AT CAP @D20_5")
	elseif point == "C1B" then
		scada=orion.GetPoint("C1B/SCADA LOCAL/REMOTE @D20_5")
		swg=orion.GetPoint("1 @Logic")
	--	swg=orion.GetPoint("C1B/43-REM LOCAL/REMOTE AT SWG @D25_5")
		cap=orion.GetPoint("C1B/43-REM LOCAL/REMOTE AT CAP @D20_5")
	elseif point == "C2" then
		scada=orion.GetPoint("C2/SCADA LOCAL/REMOTE @D20_5")
		swg=orion.GetPoint("C2/43-REM LOCAL/REMOTE @D20_5")
		cap =orion.GetPoint("1 @Logic")
	elseif point == "C2A" then
		scada=orion.GetPoint("C2A/SCADA LOCAL/REMOTE @D20_5")
		swg=orion.GetPoint("1 @Logic")
	--	swg=orion.GetPoint("C2A/43-REM LOCAL/REMOTE AT SWG @D20_5")
		cap=orion.GetPoint("C2A/43-REM LOCAL/REMOTE AT CAP @D20_5")
	elseif point == "C2B" then
		scada=orion.GetPoint("C2B/SCADA LOCAL/REMOTE @D20_5")	
		swg=orion.GetPoint("1 @Logic")
	--	swg=orion.GetPoint("C2B/43-REM LOCAL/REMOTE AT SWG @D20_5")
		cap=orion.GetPoint("C2B/43-REM LOCAL/REMOTE AT CAP @D20_5")
	elseif point == "14B(C3)" then
		scada=orion.GetPoint("14B(C3)/SCADA LOCAL/REMOTE @D20_1")
		swg=orion.GetPoint("14B(C3)/43-REM LOCAL/REMOTE @D20_1")
		cap =orion.GetPoint("1 @Logic")
	elseif point == "C3A" then
		scada=orion.GetPoint("C3A/SCADA LOCAL/REMOTE @D20_1")
		-- swg=orion.GetPoint("C3A/43-REM LOCAL/REMOTE AT SWG @D20_1")
		swg=orion.GetPoint("1 @Logic")
		cap =orion.GetPoint("C3A/43-REM LOCAL/REMOTE AT CAP @D20_1")
	elseif point == "C3B" then
		scada=orion.GetPoint("C3B/SCADA LOCAL/REMOTE @D20_1")
		-- swg=orion.GetPoint("C3B/43-REM LOCAL/REMOTE AT SWG @D20_1")
		swg=orion.GetPoint("1 @Logic")
		cap =orion.GetPoint("C3B/43-REM LOCAL/REMOTE AT CAP @D20_1")
	end
	
	scada_val = scada.value
	swg_val = swg.value
	cap_val = cap.value
	
	orion.PrintDiag(point.."  SCADA:"..scada_val.." CAP:"..cap_val.." SWG:"..swg_val)
	
	if scada_val == 1 and swg_val == 1 and cap_val == 1 then
		logic_val = 1
		text = "REMOTE"
	else
		logic_val = 0
		text = "LOCAL"			
	end

	local logic_pt = point.."/LOCAL/REMOTE @X_BUS"..bus
	orion.PrintDiag(logic_pt.." = "..text)
	orion.SetPoint({name=logic_pt, value=logic_val, online=true})
	LR_MISMATCH()	-- Check for a SCADA BUS MISMATCH any time a local/remote point changes
end	

	
function LR_MISMATCH()  -- this function is called whenever a Local/Remote point changes state
	local LR={}
	local xbus_lr={}
	local printstring, results
	local source, ON, OFF, num_bkrs, LR_val, bus, LR_name, xbus, BusSection, xbus_val, mismatch
	local SubstationMismatch = 0
	local SubstationStatus = nil
		
	orion.PrintDiag(" ")
	
	for busname in pairs (LR_Mismatch_Table) do	
		source  = LR_Mismatch_Table[busname]["D20"]
		-- orion.PrintLog(busname.." on "..source)
		num_bkrs = #LR_Mismatch_Table[busname]["Breakers"]
		OFF = 0
		ON = 1
		BusSection = orion.Right(busname,2)
		xbus = BusSection.."_MISMATCH @X_BUS"..orion.Left(BusSection,1)
		-- orion.PrintDiag(" ")
		-- orion.PrintDiag(xbus)
		
		for bkr = 1,num_bkrs, 1 do
			LR_name = LR_Mismatch_Table[busname]["Breakers"][bkr].."/SCADA LOCAL/REMOTE @"..source
			-- orion.PrintDiag("GetPoint: "..LR_name)
			LR = orion.GetPoint(LR_name)
			LR_val = LR.value
			if LR_val == 1 then
				OFF = 1	-- set the exception, something is NOT in LOCAL
				-- orion.PrintDiag(LR_name.." is in remote")
			else
				ON = 0	-- set the exception, something is NOT in REMOTE
				-- orion.PrintDiag(LR_name.." is in local")
			end	
		end	
		xbus_lr = orion.GetPoint(xbus)
		xbus_val = xbus_lr.value
		
		-- orion.PrintDiag(BusSection..":  ON="..ON.." OFF="..OFF)
		if OFF == 0 or ON == 1 then -- all LR points match
			mismatch = 0
			if OFF == 0 then 
				printstring = "All Local/Remote points are in LOCAL"
				results ="LOCAL"
			else
				printstring = " All Local/Remote points are in REMOTE"
				results = "REMOTE"
			end	
		else	
			mismatch = 1
			printstring = "MISMATCH Local/Remote points"
			results = "MISMATCH"
			SubstationMismatch = 1
		end
		
		if SubstationStatus == nil then
			SubstationStatus = results
		elseif SubstationStatus ~= results then
			SubstationStatus = "MISMATCH"
			SubstationMismatch = 1
		end	
		
		orion.SetPoint({name=xbus, value=mismatch, string=results, online=true})
		if xbus_val ~= mismatch then --  change the mismatch value
			orion.PrintDiag(BusSection..":  "..printstring)
		end
	end	
	orion.SetPoint({name="MISMATCH @SUBSTATION", value=SubstationMismatch, string=SubstationStatus, online=true})
end

function SCADA_BLOCKING(PointName)
	
	output ={}
	LR ={}
	output = orion.GetPoint(PointName)
	output_value = output.value
	
	local slash = string.find(PointName,"/")
	local point = orion.Left(PointName,slash-1)
	
	local at = string.find(PointName," @")
	local bar = string.find(PointName,"|")
	local D20 = orion.Mid(PointName,bar+1,at-bar-1)
	local cntl = orion.Left(PointName,bar-1).." @"..D20
	
	LR_name = point.."/SCADA LOCAL/REMOTE @"..D20
	LR=orion.GetPoint(LR_name)
	LR_value  = LR.value
	-- Permit SCADA command to execute only if LR_value = 1 (in remote)
	if LR_value == 1 then
		orion.SetPoint({name = cntl, value = output_value, online=true})
	else
		orion.PrintDiag(PointName.." blocked by LOCAL control")
	end		
end

function TOTAL_LOAD_Timer()
	local P1 = orion.GetPoint("T1/XFMR TOTAL WATTS P_TOT @D25_1").value
	if P1 == nil then P1 = 0 end
	local Q1 = orion.GetPoint("T1/XFMR TOTAL VARS Q_TOT @D25_1").value
	if Q1 == nil then Q1 = 0 end
	local P2 = orion.GetPoint("T2/XFMR TOTAL WATTS P_TOT @D25_2").value
	if P2 == nil then P2 = 0 end
	local Q2 = orion.GetPoint("T2/XFMR TOTAL VARS Q_TOT @D25_2").value
	if Q2 == nil then Q2 = 0 end
	local P3 = orion.GetPoint("T3/XFMR TOTAL WATTS P_TOT @D25_3").value
	if P3 == nil then P3 = 0 end
	local Q3 = orion.GetPoint("T3/XFMR TOTAL VARS Q_TOT @D25_3").value
	if Q3 == nil then Q3 = 0 end
	local P4 = orion.GetPoint("T4/XFMR TOTAL WATTS P_TOT @D25_4").value
	if P4 == nil then P4 = 0 end
	local Q4 = orion.GetPoint("T4/XFMR TOTAL VARS Q_TOT @D25_4").value
	if Q4 == nil then Q4 = 0 end
	local P5 = orion.GetPoint("T5/XFMR TOTAL WATTS P_TOT @D25_5").value
	if P5 == nil then P5 = 0 end
	local Q5 = orion.GetPoint("T5/XFMR TOTAL VARS Q_TOT @D25_5").value
	if Q5 == nil then Q5 = 0 end
	local P_total = P1+P2+P3+P4+P5
	local Q_total = Q1+Q2+Q3+Q4+Q5
	orion.SetPoint({name="TOTAL_WATTS P_TOT @SUBSTATION",value=P_total,online=true})
	orion.SetPoint({name="TOTAL_VARS Q_TOT @SUBSTATION",value=Q_total,online=true})
end

function RenameCSVFile_Timer()
     local lfs = require"lfs"
     local directory = "/usr/local/csvFileGenerator/archive/"
     
     for filename in lfs.dir(directory) do
         if string.find(filename,".CSV") ~= nil then
		--       orion.PrintDiag("Renamed File " .. filename .. " to CurrentPointValues.CSV")
              os.rename(directory .. filename, directory .. "CurrentPointValues.csv")
         end
     end
end

--should be tied to any input points that should trigger event retrieval
--assumes naming convention of "devname/..."
--code will strip out "/" and everything after it and use 'devname' to match specific entry in tbl_SEL
function SEL_Triggered(point)
	local feeder_exists = false
	
	if orion.GetPoint(point).value == g_bkr_normal then -- ignore return to normal
		return
	end
	
	local feeder = string.gsub(point, "/.*", "")
	
	for key,value in pairs(tbl_SEL) do
		if tbl_SEL[key].name == feeder then
			index = key
			feeder_exists = true
			break
		end
	end
	
	if feeder_exists then
		Print("Event detected. Feeder: '"..feeder.."' added to event retrieval queue.",1)
		table.insert(tbl_SEL_Queue,index)
		orion.EnableTimer("SEL_State")
	else
		Print(feeder.." not found in device table.",1)
	end
end

--enabled as long as one or more entries exist in the queue
--calls state function
--disables self after queue is empty
function SEL_State_Timer()
	if table.getn(tbl_SEL_Queue) > 0 then
		SEL_State_Check(tbl_SEL_Queue[1])
	else
		Print("Event retrieval queue empty.",0)
		orion.DisableTimer("SEL_State")
	end
end

function CheckForEvent_Timer()
local rly_indx, relay
	
-- START GE RELAYS	
	-- go through all GE relays and see if there are any new events by comparing event counter.  Set pending flag if new event is detected.
	for rly_indx, relay in ipairs( tbl_GERelays ) do
		local NewValue = orion.GetPoint(relay.PointName).value
		if  NewValue > relay.OldValue then
			relay.PendingEvent = true
			orion.PrintDiag("Event Detected For " .. relay.Name)
		end
		relay.OldValue = NewValue -- do outside loop incase relay events are cleared and return to 0
	end
	
	-- go through GE relays and look for any that have pending events. Start transfer and clear flag if transfer started.
	for rly_indx, relay in ipairs( tbl_GERelays ) do
		if relay.PendingEvent == true then
			if my_ge_comtrade.start_comtrade_transfer(relay.Name, relay.IP, relay.ModbusAddress) == true then
				orion.PrintDiag("Started Comtrade download for " .. relay.Name)
				relay.PendingEvent = false
			else
				orion.PrintDiag("Another Comtrade download in progress, will retry for " .. relay.Name)			
			end
		end
	end
-- END GE RELAYS
end

