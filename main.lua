require'word'
require'libs.table'

rawset(string, 's',        function(s,n) return s:sub(n,n) end)
rawset(string, 'isLetter', function(s)   return s:len()==1 and s:byte()>=97 and s:byte()<=122 end)

function love.load()
    love.window.setIcon(love.image.newImageData'icon.png')
    love.window.setTitle'Rüdl'
    typeFace = love.graphics.newImageFont("type.png", ' abcdefghijklmnopqrstuvwxyz')
end

local day = math.floor(os.time()/86400)
local word = words[day%#words]

local guess, guesses = {}, {}
local maxguess = 6
local state, redraw = false, true

local green  = {0,   0.58, 0.25, 100, '🟩'}
local yellow = {1,   0.92, 0,    100, '🟨'}
local grey   = {0.5, 0.5,  0.5,  100, '⬛'}
local white  = {1,   1,    1,    100}
local red    = {0.7, 0.08, 0.13, 100}

local inactiveRow, activeRow = { grey, ' ', grey, ' ', grey, ' ', grey, ' ' }

local keyhash = {}
local keyboard
local shareString = "Rüdl #"..array.find(words, word).."\n"

local function set(c, l)
    shareString = shareString..c[5]
    if keyhash[l] ~= green then
        keyhash[l] = c
    end
    return c
end

local function colour(guess, i)
    local letter = guess and guess:s(i)
    return guess and i and
    --Guessed
    (letter == word:s(i) and set(green, letter)
    or word:find(letter) and set(yellow, letter)
    or set(grey, letter))
    --Current
    or state == 'wrong' and red or white
end

function love.draw()
    local lp = love.graphics.print

    for i, guess in ipairs(guesses) do
        lp(guess, typeFace, 282, 20+(i-1)*59, 0, 0.5)
    end

    if state ~= 'win' and state ~= 'loss' then
        if redraw then
            activeRow = {
                colour(), guess[1]or' ',
                colour(), guess[2]or' ',
                colour(), guess[3]or' ',
                colour(), guess[4]or' ',
            }
        end
        lp(activeRow, typeFace, 282, 20+(#guesses)*59, 0, 0.5)

        if #guesses+1 < maxguess then
            for i=#guesses+2, maxguess do
                lp(inactiveRow, typeFace, 282, 20+(i-1)*59, 0, 0.5)
            end
        end

        if redraw then
            keyboard = {}
            for c in string.gmatch("qwertyuiop\nasdfghjkl\nzxcvbnm", '.') do
                table.insert(keyboard, keyhash[c] or white)
                table.insert(keyboard, c)
            end
        end
        love.graphics.printf(keyboard, typeFace, 194, 420, 1180, 'center', 0, 0.35)
    end
    redraw = false
end

function love.keypressed(key, scan, rep)
    if (state == 'win' or state == 'loss') then
        if key == 'c' then -- could check ctrl, but like, why
            love.system.setClipboardText(shareString)
        end
    else
        redraw = true
        if key:isLetter() then
            if state == 'wrong' then
                guess = {}
                state = false
            end
            if #guess < 4 then
                table.insert(guess, key)
            end
        elseif key == 'backspace' then
            state = false
            table.remove(guess)
        elseif #guess == 4 and (key == 'return' or key == 'kpenter') then
            local guessed = guess[1]..guess[2]..guess[3]..guess[4]
            if not array.find(words, guessed) then
                state = 'wrong'
            else
                table.insert(guesses, {
                    colour(guessed,1), guess[1],
                    colour(guessed,2), guess[2],
                    colour(guessed,3), guess[3],
                    colour(guessed,4), guess[4],
                })
                guess = {}
                if guessed == word then
                    state = 'win'
                elseif #guesses == maxguess then
                    state = 'loss'
                else
                    shareString = shareString.."\n"
                end
            end
        end
    end
end
