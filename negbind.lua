for i=1,100 do
	timer.Simple(i/100,function() RunConsoleCommand("impulse", "101") end )
end
RunConsoleCommand("give", "weapon_nomad_remake")