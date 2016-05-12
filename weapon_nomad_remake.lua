
AddCSLuaFile();

SWEP.Category				= "Arcadium";
SWEP.PrintName				= "Nomad";
SWEP.Author					= "Chad Barrett, Straight_Bender";
SWEP.Contact				= "cdbarrett@gmail.com, noisysomebody@gmail.com";
SWEP.Purpose				= "Rechargeable energy weapon";
SWEP.Instructions			= "Use left click to shoot energy particles, Use right click to instakill.";

SWEP.WorldModel				= "models/weapons/w_nomad.mdl";
SWEP.ViewModel				= "models/weapons/c_nomad.mdl";
SWEP.UseHands				= true;
SWEP.ViewModelFOV			= 54;

SWEP.Slot					= 2;
SWEP.SlotPos				= 0;
SWEP.Weight					= 5;

SWEP.SwayScale				= 1.0;
SWEP.BobScale				= 1.0;

SWEP.AutoSwitchTo			= true;
SWEP.AutoSwitchFrom			= true;

SWEP.Spawnable				= true;
SWEP.AdminSpawnable			= false;

SWEP.Primary.ClipSize		= 10;
SWEP.Primary.DefaultClip	= 10;
SWEP.Primary.Automatic		= true;
SWEP.Primary.Ammo			= "";

SWEP.Secondary.ClipSize		= 10;
SWEP.Secondary.DefaultClip	= 10;
SWEP.Secondary.Automatic	= false;
SWEP.Secondary.Ammo			= "";

SWEP.ShootSound				= "nomad/shoot.wav";		-- by aust_paul (http://www.freesound.org/people/aust_paul/sounds/30935/)
SWEP.EmptySound				= "buttons/combine_button1.wav";

SWEP.Damage					= 15;
SWEP.FireRate				= 0.1;
SWEP.EmptyFireRate			= 0.2;
SWEP.RegenerateRate			= 0.075;
SWEP.RegenerateDelay		= 0.85;
SWEP.MaxEnergy				= 50;
SWEP.Spread					= 0.02;
SWEP.FirstFire				= False;

SWEP.SecondDamage			= -1;
SWEP.SecondFireRate			= 1;
SWEP.SecondRegenerateRate	= 1.5;
SWEP.SecondRegenerateDelay	= 5;
SWEP.SecondFire				= False;
if( SERVER ) then

	AccessorFunc( SWEP, "fNPCMinBurst", "NPCMinBurst" );
	AccessorFunc( SWEP, "fNPCMaxBurst", "NPCMaxBurst" );
	AccessorFunc( SWEP, "fNPCFireRate", "NPCFireRate" );
	AccessorFunc( SWEP, "fNPCMinRestTime", "NPCMinRest" );
	AccessorFunc( SWEP, "fNPCMaxRestTime", "NPCMaxRest" );
	
	resource.AddFile( "models/weapons/v_nomad.mdl" );
	resource.AddFile( "models/weapons/w_nomad.mdl" );
	resource.AddFile( "materials/vgui/entities/weapon_nomad.vmt" );
	resource.AddFile( "materials/nomad/glow.vmt" );
	resource.AddFile( "materials/nomad/muzzle.vmt" );
	resource.AddFile( "materials/nomad/scorch.vmt" );
	resource.AddFile( "materials/nomad/scorch_model.vmt" );
	resource.AddFile( "materials/models/weapons/v_nomad/texture4.vmt" );
	resource.AddFile( "materials/models/weapons/v_nomad/texture5.vmt" );
	resource.AddFile( "materials/models/weapons/v_nomad/v_smg1_sheet.vmt" );
	resource.AddFile( "materials/models/weapons/w_nomad/smg_crosshair.vmt" );
	resource.AddFile( "materials/models/weapons/w_nomad/w_smg2.vmt" );
	resource.AddFile( "sound/nomad/whiz.wav" );
	resource.AddFile( "sound/nomad/shoot.wav" );
	
	function SWEP:SetIdleTime( time )

		self.NextIdleTime = CurTime() + time;

	end

	
	function SWEP:SetRegenTime( time )

		self.NextRegenTime = CurTime() + time;

	end


	function SWEP:IdleTime()

		return self.NextIdleTime;

	end

	
	function SWEP:RegenTime()

		return self.NextRegenTime;

	end


	function SWEP:TakeEnergy( amt )

		self:SetEnergyVar( math.max( 0, self:GetEnergyVar() - amt ) );

	end

	
	function SWEP:GiveEnergy( amt )

		self:SetEnergyVar( math.min( self.MaxEnergy, self:GetEnergyVar() + amt ) );

	end

	
	function SWEP:TakePrimaryAmmo( amt )

		self:TakeEnergy( amt );

	end

	
	function SWEP:ShouldDropOnDie()

		return false;

	end

	
	function SWEP:NPCShoot_Primary( pos, dir )

		if( not IsValid( self.Owner ) ) then return; end
		
		self:PrimaryAttack();

	end


	function SWEP:NPCShoot_Secondary( pos, dir )

		if( not IsValid( self.Owner ) ) then return; end
		
		self:SecondaryAttack();

	end


	function SWEP:GetCapabilities()

		return bit.bor( CAP_WEAPON_RANGE_ATTACK1, CAP_INNATE_RANGE_ATTACK1 );

	end
	
end


if( CLIENT ) then

	killicon.AddFont( "weapon_nomad", "HL2MPTypeDeath", "/", Color( 255, 128, 255, 255 ) );

	local AmmoDisplay = {};

	function SWEP:CustomAmmoDisplay()

		AmmoDisplay.Draw = true;
		AmmoDisplay.PrimaryClip = self:GetEnergy();
		AmmoDisplay.PrimaryAmmo = -1;
		AmmoDisplay.SecondaryClip = -1;
		AmmoDisplay.SecondaryAmmo = -1;

		return AmmoDisplay;

	end

end


function SWEP:Initialize()

	self:SetupDataTables();
	
	self:SetWeaponHoldType( "smg" );
	
	if( SERVER ) then

		self:SetNPCMinBurst( 3 );
		self:SetNPCMaxBurst( 10 );
		self:SetNPCFireRate( self.FireRate );
		self:SetNPCMinRest( 0.5 );
		self:SetNPCMaxRest( 2 );
		
		self:SetIdleTime( 0 );
		self:SetRegenTime( 0 );
		
		self:GiveEnergy( self.MaxEnergy );

	end

end


function SWEP:SetupDataTables()

	self:InstallDataTable();
	self:NetworkVar( "Int", 0, "EnergyVar" );

end


function SWEP:WeaponSound( sound, volume, pitch )

	local shouldSuppress = SERVER and not game.SinglePlayer();
	
	if( shouldSuppress ) then SuppressHostEvents( self.Owner ); end
	self:EmitSound( sound, volume, pitch );
	if( shouldSuppress ) then SuppressHostEvents( NULL ); end

	-- there is a bug in the gmod code where it's supposed to use CHAN_WEAPON but it doesn't.

end


function SWEP:Precache()

	util.PrecacheSound( self.ShootSound );

end


function SWEP:SetNextFire( time )

	self:SetNextPrimaryFire( CurTime() + time );
	self:SetNextSecondaryFire( CurTime() + time );

end


function SWEP:GetEnergy()

	return self:GetEnergyVar();

end


function SWEP:ShootBullet( damage, num, cone )

	local bullet = {};
	bullet.Num = num;
	bullet.Src = self.Owner:GetShootPos();
	bullet.Dir = self.Owner:GetAimVector();
	bullet.Spread = Vector( cone, cone, 0 );
	bullet.Tracer = 1;
	bullet.Force = 100;
	bullet.Damage = damage;
	bullet.AmmoType = "Pistol";
	bullet.TracerName = "NomadTracer";
	bullet.Callback = function( attacker, tr, dmginfo )

		dmginfo:SetDamageType( bit.bor( DMG_ENERGYBEAM, DMG_DISSOLVE ) );

	end
	
	self.Owner:FireBullets( bullet, true );
	
	self:ShootEffects();

end


function SWEP:ShootEffects()

	self.Owner:MuzzleFlash();
	self.Owner:SetAnimation( PLAYER_ATTACK1 );
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
	
	self:WeaponSound( self.ShootSound );
	
	-- we just played an animation, so don't play an idle animation again until it's over.
	if( SERVER ) then

		self:SetIdleTime( self:SequenceDuration() );

	end

end


function SWEP:CanPrimaryAttack()

	-- npcs get unlimited ammo because they don't know how to stop shooting!
	-- i could set the rest time, but this is quicker and easier.
	if( self.Owner:IsNPC() ) then return true; end
	if( self:GetEnergy() >= 1 ) then return true; end
	
	return false;

end


function SWEP:Empty()

	self:WeaponSound( self.EmptySound );
	self:SetNextFire( self.EmptyFireRate );

end


function SWEP:PrimaryAttack()

	self:SetNextFire( self.FireRate );
	
	-- don't regenerate ammo if they're just holding down the fire button
	-- make them stop to cool it off.
	if( SERVER ) then
		self.SecondFire = false;
		self.FirstFire = true;
		self:SetRegenTime( self.RegenerateDelay );

	end

	-- do we have enoguh energy to fire?
	if( not self:CanPrimaryAttack() ) then

		self:Empty();
		return true;

	end
	
	-- consume energy
	if( SERVER ) then

		self:TakePrimaryAmmo( 1 );

	end
	
	self:ShootBullet( self.Damage, 1, self.Spread );
	
	return true;

end


function SWEP:SecondaryAttack()
self:SetNextFire( self.SecondFireRate );
	
	-- don't regenerate ammo if they're just holding down the fire button
	-- make them stop to cool it off.
	if( SERVER ) then
		self.FirstFire = false;
		self.SecondFire = true;
		self:SetRegenTime( self.SecondRegenerateDelay );

	end

	-- do we have enoguh energy to fire?
	if( not self:CanPrimaryAttack() ) then

		self:Empty();
		return true;

	end
	
	-- consume energy
	if( SERVER ) then

		self:TakePrimaryAmmo( 10 );

	end
	
	self:ShootBullet( self.SecondDamage, 2, self.Spread );
	
	return true;
	
end


function SWEP:Think()

	if( not SERVER ) then return; end
	
	-- ammo regeneration
	if( self:RegenTime() <= CurTime() ) then 
			self:GiveEnergy( 1 );
			self:SetRegenTime( self.SecondRegenerateRate );
	end
	
	-- idle animations
	if( self:IdleTime() <= CurTime() ) then

		self:SendWeaponAnim( ACT_VM_IDLE );
		self:SetIdleTime( self:SequenceDuration() );

	end

end


function SWEP:FireAnimationEvent( pos, ang, event, options )

	-- we don't want shell casings
	if( event == 6001 ) then return true; end
	
	-- custom muzzle flash
	if( event == 21 or event == 22 ) then

		local effect = EffectData();
		effect:SetOrigin( pos );
		effect:SetAngles( ang );
		effect:SetEntity( self );
		effect:SetAttachment( 1 );

		util.Effect( "NomadMuzzle", effect );
		
		return true;
	end

end


function SWEP:DoImpactEffect( tr, dmgtype )

	if( tr.HitSky ) then return true; end
	
	util.Decal( "fadingscorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal );
	
	-- is this even the correct way to handle this?
	if( game.SinglePlayer() or SERVER or not self:IsCarriedByLocalPlayer() or IsFirstTimePredicted() ) then

		local effect = EffectData();
		effect:SetOrigin( tr.HitPos );
		effect:SetNormal( tr.HitNormal );

		util.Effect( "NomadImpact", effect );

		local effect = EffectData();
		effect:SetOrigin( tr.HitPos );
		effect:SetStart( tr.StartPos );
		effect:SetDamageType( dmgtype );

		util.Effect( "RagdollImpact", effect );
	end

    return true;

end


function SWEP:SetupWeaponHoldTypeForAI( t )

	self.ActivityTranslateAI = {};
	
	self.ActivityTranslateAI[ ACT_IDLE ]						= ACT_IDLE_PISTOL;
    self.ActivityTranslateAI[ ACT_IDLE_ANGRY ]					= ACT_IDLE_ANGRY_PISTOL;
    self.ActivityTranslateAI[ ACT_RANGE_ATTACK1 ]				= ACT_RANGE_ATTACK_PISTOL;
    self.ActivityTranslateAI[ ACT_RELOAD ]						= ACT_RELOAD_PISTOL;
    self.ActivityTranslateAI[ ACT_WALK_AIM ]					= ACT_WALK_AIM_PISTOL;
    self.ActivityTranslateAI[ ACT_RUN_AIM ]						= ACT_RUN_AIM_PISTOL;
    self.ActivityTranslateAI[ ACT_GESTURE_RANGE_ATTACK1 ]		= ACT_GESTURE_RANGE_ATTACK_PISTOL;
	self.ActivityTranslateAI[ ACT_RELOAD_LOW ]					= ACT_RELOAD_PISTOL_LOW;
    self.ActivityTranslateAI[ ACT_RANGE_ATTACK1_LOW ]			= ACT_RANGE_ATTACK_PISTOL_LOW;
    self.ActivityTranslateAI[ ACT_COVER_LOW ]					= ACT_COVER_PISTOL_LOW;
    self.ActivityTranslateAI[ ACT_RANGE_AIM_LOW ]				= ACT_RANGE_AIM_PISTOL_LOW;
    self.ActivityTranslateAI[ ACT_GESTURE_RELOAD ]				= ACT_GESTURE_RELOAD_PISTOL;
	
	-- we only want the smg hold type, ignore all others
	if( t == "smg" ) then
		
		self.ActivityTranslateAI[ ACT_RANGE_ATTACK1 ]			= ACT_RANGE_ATTACK_SMG1;
		self.ActivityTranslateAI[ ACT_RELOAD ]					= ACT_RELOAD_SMG1;
		self.ActivityTranslateAI[ ACT_IDLE ]					= ACT_IDLE_SMG1;
		self.ActivityTranslateAI[ ACT_IDLE_ANGRY ]				= ACT_IDLE_ANGRY_SMG1;
		self.ActivityTranslateAI[ ACT_WALK ]					= ACT_WALK_RIFLE;
		self.ActivityTranslateAI[ ACT_WALK_AIM ]				= ACT_WALK_AIM_RIFLE;
		self.ActivityTranslateAI[ ACT_IDLE_RELAXED ]			= ACT_IDLE_SMG1_RELAXED;
		self.ActivityTranslateAI[ ACT_IDLE_STIMULATED ]			= ACT_IDLE_SMG1_STIMULATED;
		self.ActivityTranslateAI[ ACT_IDLE_AGITATED ]			= ACT_IDLE_ANGRY_SMG1;
		self.ActivityTranslateAI[ ACT_WALK_RELAXED ]			= ACT_WALK_RIFLE_RELAXED;
		self.ActivityTranslateAI[ ACT_WALK_STIMULATED ]			= ACT_WALK_RIFLE_STIMULATED;
		self.ActivityTranslateAI[ ACT_WALK_AGITATED ]			= ACT_WALK_AIM_RIFLE;
		self.ActivityTranslateAI[ ACT_RUN_RELAXED ]				= ACT_RUN_RIFLE_RELAXED;
		self.ActivityTranslateAI[ ACT_RUN_STIMULATED ]			= ACT_RUN_RIFLE_STIMULATED;
		self.ActivityTranslateAI[ ACT_RUN_AGITATED ]			= ACT_RUN_AIM_RIFLE;
		self.ActivityTranslateAI[ ACT_IDLE_AIM_RELAXED ]		= ACT_IDLE_SMG1_RELAXED;
		self.ActivityTranslateAI[ ACT_IDLE_AIM_STIMULATED ]		= ACT_IDLE_AIM_RIFLE_STIMULATED;
		self.ActivityTranslateAI[ ACT_IDLE_AIM_AGITATED ]		= ACT_IDLE_ANGRY_SMG1;
		self.ActivityTranslateAI[ ACT_WALK_AIM_RELAXED ]		= ACT_WALK_RIFLE_RELAXED;
		self.ActivityTranslateAI[ ACT_WALK_AIM_STIMULATED ]		= ACT_WALK_AIM_RIFLE_STIMULATED;
		self.ActivityTranslateAI[ ACT_WALK_AIM_AGITATED ]		= ACT_WALK_AIM_RIFLE;
		self.ActivityTranslateAI[ ACT_RUN_AIM_RELAXED ]			= ACT_RUN_RIFLE_RELAXED;
		self.ActivityTranslateAI[ ACT_RUN_AIM_STIMULATED ]		= ACT_RUN_AIM_RIFLE_STIMULATED;
		self.ActivityTranslateAI[ ACT_RUN_AIM_AGITATED ]		= ACT_RUN_AIM_RIFLE;
		self.ActivityTranslateAI[ ACT_WALK_CROUCH ]				= ACT_WALK_CROUCH_RIFLE;
		self.ActivityTranslateAI[ ACT_WALK_CROUCH_AIM ]			= ACT_WALK_CROUCH_AIM_RIFLE;
		self.ActivityTranslateAI[ ACT_RUN ]						= ACT_RUN_RIFLE;
		self.ActivityTranslateAI[ ACT_RUN_AIM ]					= ACT_RUN_AIM_RIFLE;
		self.ActivityTranslateAI[ ACT_RUN_CROUCH ]				= ACT_RUN_CROUCH_RIFLE;
		self.ActivityTranslateAI[ ACT_RUN_CROUCH_AIM ]			= ACT_RUN_CROUCH_AIM_RIFLE;
		self.ActivityTranslateAI[ ACT_GESTURE_RANGE_ATTACK1 ]	= ACT_GESTURE_RANGE_ATTACK_AR2;
		self.ActivityTranslateAI[ ACT_COVER_LOW ]				= ACT_COVER_SMG1_LOW;
		self.ActivityTranslateAI[ ACT_RANGE_AIM_LOW ]			= ACT_RANGE_AIM_AR2_LOW;
		self.ActivityTranslateAI[ ACT_RANGE_ATTACK1_LOW ]		= ACT_RANGE_ATTACK_SMG1_LOW;
		self.ActivityTranslateAI[ ACT_RELOAD_LOW ]				= ACT_RELOAD_SMG1_LOW;
		self.ActivityTranslateAI[ ACT_GESTURE_RELOAD ]			= ACT_GESTURE_RELOAD_SMG1;

	end

end

