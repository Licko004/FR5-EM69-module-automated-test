

-- SetDO(0, 0, 0, 1)

-- Turning vacuum ON and OFF after 5 seconds
SetToolDO(0, 1, 0, 1)
WaitMs(300)
SetToolDO(0, 0, 0, 1)

-- WaitMs(5000)

-- SetToolDO(0, 1, 0, 1)
-- WaitMs(300)
-- SetToolDO(0, 0, 0, 1)

-- Tool DI aquisition test
-- function lim_sw_state(io_num)
--     state = GetToolDI(io_num, 0)
--     return state
-- end

-- while(1) do
--     state = lim_sw_state(0)
--     RegisterVar("number", "state")
-- end
