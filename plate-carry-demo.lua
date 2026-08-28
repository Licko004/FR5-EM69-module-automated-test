-- FR5 cobot testing demo, using 1 coord. system, custom vacuum gripper and trays to house the modules --

local user = 1          -- used coordinate system, set it in WEB UI
local tool   = 1        -- tool index used by every MoveJ
local vel    = 100       -- programmed speed [%]
local acc    = 100      -- acceleration [%]
local ovl    = 100       -- velocity override [%]
local blendT = 200.0    -- joint blend time [ms]; -1 = blocking
local e1, e2, e3, e4 = 0, 0, 0, 0   -- external-axis positions
local offset_flag = 0


-- Extra variables
local part_count = 0

-- Tray grid pitches (mm)
TR1_PITCH_Y, TR1_PITCH_X = 32.8, 56
TR2_PITCH_Y, TR2_PITCH_X = -32.57, -55.1

TR2_COLS = 8
TR2_ROWS = 4

TR1_COLS = 7
TR1_ROWS = 4

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

function magnet_release(state) -- 1 = release, 0 = hold
    SetToolDO(1, state, 0, 1)
end

-- Move to TR1_TOP_OUT 
PTP(TR1_TOP_OUT, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0)

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

                    WaitMs(200)

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
        Lin(TEST_RELEASE, 30, -1, 0, 1, 0, 0, 0, 0, 0, 0, 0)
        Lin(TEST, 30, -1, 0, 1, 0, 0, 0, 0, 0, 0, 0)

        vacuum_toggle() -- turn vacuum OFF
        WaitMs(2000)

        Lin(TEST_RELEASE, ovl, -1, 0, 1, 0, 0, 0, 0, 0, 0, 0)

        vacuum_toggle() 
        WaitMs(500)

        PTP(TEST_APP, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0)

        Lin(TR2_BTM, ovl, -1, 0, 1, x2, y2, 200, 0, 0, 0)  -- above target slot (z = 200, to clear all trays and modules)
        Lin(TR2_BTM, ovl, -1, 0, 1, x2, y2, -1, 0, 0, 0)        -- descend to place height

        vacuum_toggle()  -- release part
        WaitMs(1000)

        Lin(TR2_BTM, ovl, -1, 0, 1, x2, y2, 30 + 30, 0, 0, 0)  -- retract

        PTP(TR2_APP, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0)     -- back to TR2 approach
        PTP(TR1_TOP_OUT, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0)

        m = m + 1 -- increment m, to move to next position in tray 1
    end
end

-- TRAY 1 PICK AND CARRY ONTO TRAY 2 SEQUENCE
PTP(TR1_LIFT, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0)
Lin(TR1_PICK, 20, -1, 0, 1, 0, 0, 0, 0, 0, 0, 0)
WaitMs(200)
Lin(TR1_LIFT, 20, -1, 0, 1, 0, 0, 0, 0, 0, 0, 0)

PTP(TR2_LIFT, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0)
Lin(TR2_PLACE, 20, -1, 0, 1, 0, 0, 0, 0, 0, 0, 0)

magnet_release(1)
WaitMs(300)

Lin(TR2_LIFT, 20, -1, 0, 1, 0, 0, 0, 0, 0, 0, 0)

magnet_release(0)

PTP(TR2_APP, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0)
PTP(TR1_TOP_OUT, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0)



-- MOVEMENT ACCROSS TRAY 1, BOTTOM
m = 0; n = 0; h = 1
i = 7; j = 4; k = 2  -- i = nr. of COLUMNS, j = nr. of ROWS, k = nr. of layers

switchTripped = false
part_count2 = 0

tray_gap = 52

while (part_count2 < TR2_COLS*TR2_ROWS and h < k) do

    switchTripped = false

    while (h < k) do
        while (n < j) do
            while (m < i) do

                if (n == 2 and m == 2) then
                    m = 6
                else
                    Lin(TR1_TOP, ovl, -1, 0, 1, -0.002*m + 56.254*n, 32.803*m + -0.004*n, 10, 0, 0, 0)  -- approach
                    Lin(TR1_TOP, ovl, -1, 0, 1, -0.002*m + 56.254*n, 32.803*m + -0.004*n, -tray_gap, 0, 0, 0)              -- pick

                    WaitMs(200)

                    if (lim_sw_state(0) == 1) then
                        switchTripped = true
                        break
                    end

                    Lin(TR1_TOP, ovl, -1, 0, 1, -0.002*m + 56.254*n, 32.803*m + -0.004*n, 10, 0, 0, 0)  -- approach

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

        part_count2 = part_count2 + 1
        RegisterVar("number","part_count2")

        vacuum_toggle()
        WaitMs(1000)

        Lin(TR1_TOP, ovl, -1, 0, 1, -0.002*m + 56.254*n, 32.803*m + -0.004*n, tray_gap, 0, 0, 0) -- lift module out of tray
        PTP(TR1_TOP_OUT, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0) -- clear of TR1
        PTP(TR2_APP, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0)     -- approach TR2

        -- Compute target slot in TR2 from part_count, row-major (fill row, then next row)
        idx  = part_count2 - 1

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
        Lin(TEST_RELEASE, 30, -1, 0, 1, 0, 0, 0, 0, 0, 0, 0)
        Lin(TEST, 30, -1, 0, 1, 0, 0, 0, 0, 0, 0, 0)

        vacuum_toggle() -- turn vacuum OFF
        WaitMs(2000)

        Lin(TEST_RELEASE, ovl, -1, 0, 1, 0, 0, 0, 0, 0, 0, 0)

        vacuum_toggle() 
        WaitMs(500)

        PTP(TEST_APP, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0)

        Lin(TR2_BTM, ovl, -1, 0, 1, x2, y2, 200, 0, 0, 0)  -- above target slot (z = 200, to clear all trays and modules)
        Lin(TR2_BTM, ovl, -1, 0, 1, x2, y2, tray_gap - 1, 0, 0, 0)        -- descend to place height

        vacuum_toggle()  -- release part
        WaitMs(1000)

        Lin(TR2_BTM, ovl, -1, 0, 1, x2, y2, tray_gap*2, 0, 0, 0)  -- retract

        PTP(TR2_APP, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0)     -- back to TR2 approach
        PTP(TR1_TOP_OUT, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0)

        m = m + 1 -- increment m, to move to next position in tray 1
    end
end


-- PICK MODULES OUT OF TR2_TOP and PLACE THEM INTO TR1_BTM
PTP(TR2_APP, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0) 

-- Manual test
-- part_count2 = 3

module_count = 0
local total_placed = part_count2

while(module_count < total_placed) do

    idx = total_placed - 1 - module_count   -- last placed gets picked first (reverse order)

    if (idx >= 18 and idx <= 21) then
        idx = 22
    end

    col2 = idx % TR2_COLS
    row2 = (idx - col2) / TR2_COLS

    x2 = row2 * TR2_PITCH_X
    y2 = col2 * TR2_PITCH_Y

    Lin(TR2_BTM, ovl, -1, 0, 1, x2, y2, tray_gap + 30, 0, 0, 0)
    Lin(TR2_BTM, ovl, -1, 0, 1, x2, y2, tray_gap - 22, 0, 0, 0)

    vacuum_toggle()
    WaitMs(500)

    Lin(TR2_BTM, ovl, -1, 0, 1, x2, y2, tray_gap + 70, 0, 0, 0)

    PTP(TR2_APP, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0)
    PTP(TR1_TOP_OUT, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0)

    col1 = module_count % TR1_COLS
    row1 = (module_count - col1) / TR1_COLS

    x1 = row1 * TR1_PITCH_X
    y1 = col1 * TR1_PITCH_Y

    Lin(TR1_TOP, ovl, -1, 0, 1, x1, y1, 10, 0, 0, 0)
    Lin(TR1_TOP, ovl, -1, 0, 1, x1, y1, -tray_gap + 21, 0, 0, 0)

    vacuum_toggle()
    WaitMs(500)

    Lin(TR1_TOP, ovl, -1, 0, 1, x1, y1, 10, 0, 0, 0)

    module_count = module_count + 1

    PTP(TR1_TOP_OUT, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0)
    PTP(TR2_APP, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0) 

end

-- TRAY 2 PICK and PLACE ON TOP OF TR1_BTM
PTP(TR2_LIFT, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0)
Lin(TR2_PLACE, 20, -1, 0, 1, 0, 0, 0, 0, 0, 0, 0)
WaitMs(200)
Lin(TR2_LIFT, 20, -1, 0, 1, 0, 0, 0, 0, 0, 0, 0)

PTP(TR1_LIFT, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0)
Lin(TR1_PICK, 20, -1, 0, 1, 0, 0, 0, 0, 0, 0, 0)

magnet_release(1)
WaitMs(300)

Lin(TR1_LIFT, 20, -1, 0, 1, 0, 0, 0, 0, 0, 0, 0)

magnet_release(0)
WaitMs(300)

PTP(TR1_TOP_OUT, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0)
PTP(TR2_APP, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0) 


-- PICK MODULES OUT OF TR2_BTM and PLACE THEM INTO TR1_TOP

-- Manual test
-- part_count = 3

module_count2 = 0
local total_placed2 = part_count

while(module_count2 < total_placed2) do

    idx = total_placed2 - 1 - module_count2   -- last placed gets picked first (reverse order)

    if (idx >= 18 and idx <= 21) then
        idx = 22
    end

    col2 = idx % TR2_COLS
    row2 = (idx - col2) / TR2_COLS

    x2 = row2 * TR2_PITCH_X
    y2 = col2 * TR2_PITCH_Y

    Lin(TR2_BTM, ovl, -1, 0, 1, x2, y2, 30 + 30, 0, 0, 0)
    Lin(TR2_BTM, ovl, -1, 0, 1, x2, y2, - 22, 0, 0, 0)

    vacuum_toggle()
    WaitMs(500)

    Lin(TR2_BTM, ovl, -1, 0, 1, x2, y2, 30 + 30, 0, 0, 0)

    PTP(TR2_APP, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0)
    PTP(TR1_TOP_OUT, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0)

    col1 = module_count2 % TR1_COLS
    row1 = (module_count2 - col1) / TR1_COLS

    x1 = row1 * TR1_PITCH_X
    y1 = col1 * TR1_PITCH_Y

    Lin(TR1_TOP, ovl, -1, 0, 1, x1, y1, 60, 0, 0, 0)
    Lin(TR1_TOP, ovl, -1, 0, 1, x1, y1, 22, 0, 0, 0)

    vacuum_toggle()
    WaitMs(1000)

    Lin(TR1_TOP, ovl, -1, 0, 1, x1, y1, 60, 0, 0, 0)

    module_count2 = module_count2 + 1

    PTP(TR1_TOP_OUT, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0)
    PTP(TR2_APP, ovl, blendT, offset_flag, 0, 0, 0, 0, 0, 0) 

end