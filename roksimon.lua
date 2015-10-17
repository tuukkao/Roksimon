-- roksimon.lua
-- (c) 2012-2015 Tuukka Ojala <tuukka.ojala@gmail.com>

-- we'll need these for the constants.
require ("buttons")-- we need these for the constants.

-- tone frequencies and button constants
tones = {}
tones [rb.buttons.BUTTON_UP] = 262 -- c4
tones [rb.buttons.BUTTON_RIGHT] = 330 -- e4
tones [rb.buttons.BUTTON_DOWN] = 392 -- g4
tones [rb.buttons.BUTTON_LEFT] =523 -- c5

-- file paths
highscore_path = rb.PLUGIN_GAMES_DATA_DIR .. '/roksimon.hs'
stats_path = '/roksimon_stats.txt'
volume_path = rb.PLUGIN_GAMES_DATA_DIR .. '/roksimon.vol'

function beep (freq, amp, block)
    -- Makes a 200 ms long beep in the specified pitch and optionally blocks the script for the time of the beep.
    amp = amp or vol
    block = block or false
    rb.beep_play (freq, 200, amp)
    if block then
        rb.sleep (rb.HZ / 5)
    end
end

function beep_alert (freq, amp)
    -- Same as beep but with shorter tones and fixed blocking.
    amp = amp or vol
    rb.beep_play (freq, 100, amp)
    rb.sleep (rb.HZ / 10)
end

function decrease_volume (vol)
    -- Decreases the volume by 500 steps and plays a tone.
    vol = vol -500
    if vol < 0 then
        vol = 0
    end
    rb.beep_play (523, 50, vol)
    return vol
end

function game (hs, vol)
    -- The actual game.
    -- the tones which the player has to memorise.
    local que = {}
    -- for checking the player's input.
    local freqs = get_vals (tones)
    local points = 0
    -- increases with every iteration, needed for the fill-in feature.
    local i = 1
    -- If fill-in has been used
    local used = false
    -- whether the high score has been already announced
    local announced = false
    -- the game loop
    while true do
        -- Insert a new tone into the queue
        local random = math.random (4)
        table.insert (que, freqs [random])
        -- play the queue
        for j, v in ipairs (que) do
            beep (v, vol, true)
        end
        -- The "input cursor"
        local x = 1
        -- The input loop: poll for keypresses
        while true do
            local button = rb.button_get (true)
            if is_valid (button) then
                if tones [button] == que [x] then
                    beep (que [x], vol)
                    x = x +1
                    points = points + 1
                else
                    -- Wrong tone; game over.
                    beep_alert (523, vol)
                    beep_alert (370, vol)
                    if points > hs then
                        write_highscore (points)
                    end
                    write_stats (points, i)
                    return
                end
            -- If the player filled in the rest of the queue...
            elseif button == rb.buttons.BUTTON_HOME and not used then
                used = true
                for i = x, table.maxn (que) do
                    beep (que [i], vol, true)
                    x = x + 1
                end
            -- If volume is increased...
            elseif button == rb.buttons.BUTTON_VOL_UP
                   or button == bit.bor (rb.buttons.BUTTON_VOL_UP,
                   rb.buttons.BUTTON_REPEAT) then
                vol = increase_volume (vol)
            elseif button == rb.buttons.BUTTON_VOL_DOWN
                   or button == bit.bor (rb.buttons.BUTTON_VOL_DOWN,
                   rb.buttons.BUTTON_REPEAT) then
                vol = decrease_volume (vol)
            end
            -- If the player got all the tones right...
            if x == table.maxn (que) + 1 then
                i = i + 1
                -- Re-enable fill-in every 10th iteration.
                if i % 10 == 0 then
                    used = false
                end
                rb.sleep (rb.HZ / 2)
                beep_alert (659, vol)
                beep_alert (1046, vol)
                if points > hs and not announced then
                    hs = points
                    announced = true
                    beep_alert (1174, vol)
                    beep_alert (1567, vol)
                end
                rb.sleep (rb.HZ)
                break
            end
        end
    end
end

function get_contents (path)
    -- Reads the given file and returns its contents as a number.
    file = io.open (path, "r")
    if file == nil then
        return 0
    end
    contents = tonumber (file:read ())
    file:close ()
    return contents
end

function get_vals (t)
    -- Returns an array containing the values of table t.
    local r = {}
    for k, v in pairs (t) do
        table.insert (r, v)
    end
    return r
end

function increase_volume (vol)
    -- Increases the volume by 500 steps and plays a tone.
    vol = vol + 500
    rb.beep_play (1046, 50, vol)
    return vol
end

function is_valid (b)
    -- Return true if button b is either up, down, left or right.
    if b == rb.buttons.BUTTON_UP or b == rb.buttons.BUTTON_DOWN
       or b == rb.buttons.BUTTON_LEFT or b == rb.buttons.BUTTON_RIGHT then
        return true
    else
        return false
    end
end

function main ()
    -- Where everything begins
    -- Get the high score and volume to be available in global variables.
    hs = get_contents (highscore_path)
    vol = get_contents (volume_path)
    beep_alert (523)
    beep_alert (1046)
    preview ()
end

function preview ()
    -- A mode where the user can preview the game sounds and start the game.
    local pressed_tones = {}
    local button = nil
    while button ~= rb.buttons.BUTTON_POWER do
        button = rb.button_get (true)
        if is_valid (button) then
            beep (tones [button])
            table.insert (pressed_tones, tones [button])
        elseif button == rb.buttons.BUTTON_HOME then
            for i, v in ipairs (pressed_tones) do
                beep (v, vol, true)
            end
        elseif button == rb.buttons.BUTTON_SELECT then
            game (hs, vol)
        elseif button == rb.buttons.BUTTON_VOL_UP
               or button == bit.bor (rb.buttons.BUTTON_VOL_UP,
               rb.buttons.BUTTON_REPEAT) then
            vol = increase_volume (vol)
        elseif button == rb.buttons.BUTTON_VOL_DOWN
               or button == bit.bor (rb.buttons.BUTTON_VOL_DOWN,
               rb.buttons.BUTTON_REPEAT) then
            vol = decrease_volume (vol)
        end
    end
    -- in case power was pressed
    write_contents (volume_path, vol)
    os.exit ()
end

function write_contents (path, data)
    -- Writes the given data to a file.
    file = io.open (path, "w")
    file:write (data)
    file:close ()
end

function write_stats (points, rounds)
    -- Writes game statistics to a file.
    date = os.date ("%a %b %d %H:%M:%S %Y")
    file = io.open (stats_path, "a")
    file:write (points .. ' points (' .. rounds .. ' complete rounds) on '
               .. date .. '.\r\n')
    file:close ()
end

main ()