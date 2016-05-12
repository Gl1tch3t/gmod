local grav = tostring(physenv.GetGravity());
print(grav) 
if grav == ("0.000000 0.000000 -600.000000") then
print("hi") 
	RunConsoleCommand("sv_gravity", "10");
	RunConsoleCommand("sv_friction", "0");
	RunConsoleCommand("Say", ""..grav);
else
	RunConsoleCommand("sv_gravity", "600");
	RunConsoleCommand("sv_friction", "8");
	RunConsoleCommand("say", "Second Change")
end
RunConsoleCommand("Say", "Outside Loop")