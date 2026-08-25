-- FR5 cobot testing demo, using 1 coord. system, custom vacuum gripper and trays to house the modules --

local user = 1          -- used coordinate system, set it in WEB UI
local tool   = 1        -- tool index used by every MoveJ
local vel    = 20       -- programmed speed [%]
local acc    = 100      -- acceleration [%]
local ovl    = 60       -- velocity override [%]
local blendT = 200.0    -- joint blend time [ms]; -1 = blocking
local e1, e2, e3, e4 = 0, 0, 0, 0   -- external-axis positions
local offset_flag = 0


-- Extra variables
local part_count = 0

-- Tray grid pitches (mm)
TR1_PITCH_X, TR1_PITCH_Y = 32.8, 56
TR2_PITCH_X, TR2_PITCH_Y = 32.57, 55.1

-- Point definitons 

-- Top tray1 (TR1_TOP) is defined with Matrix 1 in webUI

-- TR1_TOP = {} -- first module in tray 1, start of matrix 1
-- TR1_TOP_LAST_ROW = {}
-- TR1_TOP_LAST = {}

--TR1_BTM = {}


-- Common used functions
-- GetToolDI(io_num)

-- Helper functions:
function lim_sw_state(io_num)
    state = GetToolDI(io_num, 0)
    return state
end


function vacuum_toggle()
    SetToolDO(0, 1, 0, 1)
    WaitMs(300)
    SetToolDO(0, 0, 0, 1)
end


-- MOVEMENT ACCROSS TRAY 1, TOP
m = 0; n = 0; h = 0
i = 7; j = 4; k = 1  -- i = nr. of COLUMNS, j = nr. of ROWS, k = nr. of layers

switchTripped = false
part_count = 0

while (h < k) do
    while (n < j) do
        while (m < i) do

            Lin(TR1_TOP, 10, -1, 0, 1, -0.002*m + 56.254*n, 32.803*m + -0.004*n, 30*h + 30*(1+1), 0, 0, 0)
            Lin(TR1_TOP, 10, -1, 0, 1, -0.002*m + 56.254*n, 32.803*m + -0.004*n, 30*h, 0, 0, 0)

            WaitMs(500)

            if (lim_sw_state(0) == 1) then
                switchTripped = true
                break
            end

            Lin(TR1_TOP, 10, -1, 0, 1, -0.002*m + 56.254*n, 32.803*m + -0.004*n, 30*h + 30*(1+1), 0, 0, 0)

            RegisterVar("number", "m")
            RegisterVar("number", "n")
            RegisterVar("number", "h")

            m = m + 1
        end

        if (switchTripped) then break end
        n = n + 1
        m = 0
    end

    if (switchTripped) then break end
    m = 0
    n = 0
    h = h + 1
end

if (switchTripped) then

        part_count = part_count + 1

        vacuum_toggle() -- turn vacuum ON
        WaitMs(1000)

        Lin(TR1_TOP, 10, -1, 0, 1, -0.002*m + 56.254*n, 32.803*m + -0.004*n, 30*h + 30*(1+1), 0, 0, 0) -- lift module out of tray
        PTP(TR1_TOP_OUT, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0) -- clear of TR1
        PTP(TR2_APP, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0)     -- approach TR2

        WaitMs(1000)
        vacuum_toggle()
end


