-- Changes terrain when unit die on that tile. works mostly independend of the rest of the addon.

local on_event = wesnoth.require("on_event")

local snow = {
	"misc/blank-hex.png~BLIT(terrain/wct-snowcrater1.png~SCALE(63,63),5,5)",
	"misc/blank-hex.png~BLIT(terrain/wct-snowcrater2.png~SCALE(63,63),5,5)",
	"misc/blank-hex.png~BLIT(terrain/wct-snowcrater3.png~SCALE(54,54),9,9)"
}

local ice = {
	"misc/blank-hex.png~BLIT(terrain/water/ford-tile.png~MASK(terrain/wct-crack-7.png))",
	"misc/blank-hex.png~BLIT(terrain/water/ford-tile.png~MASK(terrain/wct-crack-2.png))",
	"misc/blank-hex.png~BLIT(terrain/water/ford-tile.png~MASK(terrain/wct-crack-3.png))",
	"misc/blank-hex.png~BLIT(terrain/water/ford-tile.png~MASK(terrain/wct-crack-4.png))",
	"misc/blank-hex.png~BLIT(terrain/water/ford-tile.png~MASK(terrain/wct-crack-5.png))"
}

--replaces terrain fo the wct  custom terrain mod.
local function wct_map_custom_ruin_village(loc)
	local map = wesnoth.map.get()
	loc = wesnoth.map.get_hex(loc)
	-- TODO: enable once https://github.com/wesnoth/wesnoth/issues/4894 is fixed.
	if false then
		if loc:matches{terrain = "*^Vh,*^Vha"} then
			map:set_terrain(loc, "*^Vhr", "overlay")
		end
		if loc:matches{terrain = "*^Vhc,*^Vhca"} then
			map:set_terrain(loc, "*^Vhr", "overlay")
		end
	end
end

on_event("die", function(cx)
	local map = wesnoth.map.get()
	local loc = wesnoth.map.get_hex(cx.x1, cx.y1)
	if wml.variables.wc2_config_enable_terrain_destruction == false then
		return
	end
	if not loc:matches{terrain = "K*^*,C*^*,*^Fet,G*^F*,G*^Uf,A*,*^B*,Rrc,Iwr,*^Vhh,*^Vh*,*^Fda*"} then
		return
	end
	local function item(image)
		wesnoth.wml_actions.item {
			x = cx.x1,
			y = cx.y1,
			image = image,
			z_order = -10,
		}
	end
	if loc:matches{terrain = "Kh,Kha,Kh^Vov,Kha^Vov"} then
		map:set_terrain(loc, "Khr", "base")

	elseif loc:matches{terrain = "Ch,Cha"} then
		map:set_terrain(loc, "Chr^Es")

		-- only without custom activated
	elseif loc:matches{terrain = "Ch^Vh,Ch^Vhc"} then
		map:set_terrain(loc, "Chr", "base")

	elseif loc:matches{terrain = "Cd"} then
		map:set_terrain(loc, "Cdr^Es")

	elseif loc:matches{terrain = "Cd^Vd"} then
		map:set_terrain(loc, "Cdr", "base")

	elseif loc:matches{terrain = "Kd"} then
		map:set_terrain(loc, "Kdr^Es")

	elseif loc:matches{terrain = "Gg^Fmf,Gg^Fdf,Gg^Fp,Gg^Uf,Gs^Fmf,Gs^Fdf,Gs^Fp,Gs^Uf"} then
		map:set_terrain(loc, "Gll", "base")

	elseif loc:matches{terrain = "Cv^Fds"} then
		map:set_terrain(loc, "Cv^Fdw")

	elseif loc:matches{terrain = "Rr^Fet,Cv^Fet"} then
		map:set_terrain(loc, "Rr^Fetd", "overlay")

	elseif loc:matches{terrain = "Aa"} then
		item(snow[wesnoth.random(#snow)])
	elseif loc:matches{terrain = "Ai"} then
		item(ice[wesnoth.random(#ice)])
	elseif loc:matches{terrain = "Ww^Bsb|,Ww^Bsb/,Ww^Bsb\\,Wwt^Bsb|,Wwt^Bsb/,Wwt^Bsb\\,Wwg^Bsb|,Wwg^Bsb/,Wwg^Bsb\\"} then
		map:set_terrain(loc, "Wwf^Edt")
		wesnoth.play_sound("water-blast.wav")
		item("scenery/castle-ruins.png")
	elseif loc:matches{terrain = "Rrc"} then
		if wesnoth.variables["bonus.theme"] == "paradise" then
			wesnoth.wml_actions.remove_item {
				x = cx.x1,
				y = cx.y1,
				image = "wc2_citadel_leanto"
			}
			item("scenery/trash.png")
			map:set_terrain(loc, "Rrc^Edt")
		end
	elseif loc:matches{terrain = "Iwr"} then
		wesnoth.wml_actions.remove_item {
			x = cx.x1,
			y = cx.y1,
			image = "wc2_dock_ship"
		}
		item("scenery/trash.png")
		map:set_terrain(loc, "Iwr^Edt")
	elseif loc:matches{terrain = "*^Vh,**^Vhc,*^Vha,**^Vhca,*^Fda"} then
		wct_map_custom_ruin_village(loc)
		if loc:matches{terrain = "Ch^V*"} then
			map:set_terrain(loc, "Chr", "base")
		end
		--  TODO: enable once https://github.com/wesnoth/wesnoth/issues/4894 is fixed.
		if false then
			if loc:matches{terrain = "*^Fda"} then
				map:set_terrain(loc, "*^Fdw", "overlay")
			end
		end
	else
		if loc:matches{terrain = "*^Vhh,*^Vhha"} then
			map:set_terrain(loc, "*^Vhhr", "overlay")
		end
		if loc:matches{terrain = "*^Bw|,*^Bw/,*^Bw\\"} then
			map:set_terrain(loc, wesnoth.map.get():get_terrain(loc) .. "r")
		end
	end
end)
