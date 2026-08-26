-- FR5 cobot testing demo, using 1 coord. system, custom vacuum gripper and trays to house the modules --

local user = 1          -- used coordinate system, set it in WEB UI
local tool   = 1        -- tool index used by every MoveJ
local vel    = 20       -- programmed speed [%]
local acc    = 100      -- acceleration [%]
local ovl    = 40       -- velocity override [%]
local blendT = 200.0    -- joint blend time [ms]; -1 = blocking
local e1, e2, e3, e4 = 0, 0, 0, 0   -- external-axis positions
local offset_flag = 0


-- Extra variables
local part_count = 0

-- Tray grid pitches (mm)
TR1_PITCH_X, TR1_PITCH_Y = 32.8, 56
TR2_PITCH_Y, TR2_PITCH_X = -32.57, -55.1

TR2_COLS = 8
TR2_ROWS = 4
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
while (part_count < TR2_COLS*TR2_ROWS and h < k) do

    switchTripped = false

    while (h < k) do
        while (n < j) do
            while (m < i) do

                if (n == 2 and m == 2) then
                    m = 6
                else
                    Lin(TR1_TOP, ovl, -1, 0, 1, -0.002*m + 56.254*n, 32.803*m + -0.004*n, 30*h + 30*(1+1), 0, 0, 0)
                    Lin(TR1_TOP, ovl, -1, 0, 1, -0.002*m + 56.254*n, 32.803*m + -0.004*n, 30*h, 0, 0, 0)

                    WaitMs(500)

                    if (lim_sw_state(0) == 1) then
                        switchTripped = true
                        break
                    end

                    Lin(TR1_TOP, ovl, -1, 0, 1, -0.002*m + 56.254*n, 32.803*m + -0.004*n, 30*h + 30*(1+1), 0, 0, 0)

                    RegisterVar("number", "m")
                    RegisterVar("number", "n")
                    RegisterVar("number", "h")

                    m = m + 1
                end

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
        RegisterVar("number","part_count")

        vacuum_toggle()
        WaitMs(1000)

        Lin(TR1_TOP, ovl, -1, 0, 1, -0.002*m + 56.254*n, 32.803*m + -0.004*n, 30*h + 30*(1+1), 0, 0, 0) -- lift module out of tray
        PTP(TR1_TOP_OUT, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0) -- clear of TR1
        PTP(TR2_APP, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0)     -- approach TR2

        -- Compute target slot in TR2 from part_count, row-major (fill row, then next row)
        idx  = part_count - 1

        if (idx >= 18 and idx <= 21) then
            idx  = 22
        end

        col2 = idx % TR2_COLS
        row2 = (idx - col2) / TR2_COLS   -- integer division without math.floor

        x2 = row2 * TR2_PITCH_X
        y2 = col2 * TR2_PITCH_Y


        RegisterVar("number", "idx")
        RegisterVar("number", "col2")
        RegisterVar("number", "row2")
        RegisterVar("number", "x2")
        RegisterVar("number", "y2")

        Lin(TR2_BTM, ovl, -1, 0, 1, x2, y2, 200, 0, 0, 0)  -- above target slot


        -- TEST THE MODULE
        PTP(TEST_APP, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0)
        Lin(TEST_RELEASE, 10, -1, 0, 1, 0, 0, 0, 0, 0, 0, 0)
        Lin(TEST, 10, -1, 0, 1, 0, 0, 0, 0, 0, 0, 0)

        vacuum_toggle() -- turn vacuum OFF
        WaitMs(2000)

        Lin(TEST_RELEASE, ovl, -1, 0, 1, 0, 0, 0, 0, 0, 0, 0)

        vacuum_toggle() 
        WaitMs(500)

        PTP(TEST_APP, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0)

        Lin(TR2_BTM, ovl, -1, 0, 1, x2, y2, 200, 0, 0, 0)  -- above target slot (z = 200, to clear all trays and modules)
        Lin(TR2_BTM, 10, -1, 0, 1, x2, y2, 0, 0, 0, 0)        -- descend to place height

        WaitMs(500)
        vacuum_toggle()  -- release part
        WaitMs(300)

        Lin(TR2_BTM, 10, -1, 0, 1, x2, y2, 30 + 30, 0, 0, 0)  -- retract

        PTP(TR2_APP, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0)     -- back to TR2 approach
        PTP(TR1_TOP_OUT, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0)

        m = m + 1 -- increment m, to move to next position in tray 1
    end
end