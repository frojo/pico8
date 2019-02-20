pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
	--clip(16, 16, 48, 48)
	rectfill(0, 0, 127, 127, 5)
	color(10)
end


function _update()
	if (btn()) cls()

end

function _draw()
	print("hello!", 16, 16, 3)
	color(10)
	print("more debug!")
	print("and some more")
	pset(16, 16, 6)
	-- fillp(0b0011010101101000)
	-- circfill(64,64,20, 0xe) -- brown and pink
	poke(0x5f34, 1) -- sets integrated fillpattern + colour mode
	circfill(64,64,20, 0x114e.abcd) -- sets fill pattern to abcd
end

