
float() RocketProject =
{
	local vector oldorg;
	oldorg = self.origin;
 
	self.origin = self.source + self.velocity * (time - self.starttime);

	//Do the trail thing, if possible.
	trailparticles(particleeffectnum("tr_rocket"), self, self.origin, oldorg);

	dynamiclight_add(self.origin, 400, '1 1 1');
	
  	return FALSE;
};

nonstatic void(float isnew) ParseRocketClass =
{
	self.starttime = time;
	self.source_x = readcoord();
    print("got x: ", ftos(self.source_x), "\n");
	self.source_y = readcoord();
    print("got y: ",ftos(self.source_y),"\n");
	self.source_z = readcoord();
    print("got z: ",ftos(self.source_z),"\n");
	self.angles_x = readcoord();
    print("got angles x:",ftos(self.angles_x),"\n");
	self.angles_y = readcoord();
    print("got angles y:",ftos(self.angles_y),"\n");
	self.angles_z = random()*360;
    print("angleszz is random\n");

	self.angles_x*=-1;
	makevectors(self.angles);
	self.angles_x*=-1;
	self.velocity = v_forward*900;
	self.origin = self.source;

	setmodel(self, "progs/missile.mdl");
	self.drawmask = MASK_ENGINE;	//general view.
	self.predraw = RocketProject;
};

nonstatic void(float isnew) ParseExplosion =
{
	local vector org;
	local entity e;
	org_x = readcoord();
	org_y = readcoord();
	org_z = readcoord();
	self.origin = org;
	if (isnew)
	{
		sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
		pointparticles(particleeffectnum("te_explosion"), org);
	}

	self.drawmask = 0;
	remove(self);	//don't draw it any more.
};

void() CS_W_Explode = {
    print("touch!");
    self.drawmask = 0;
	remove(self);
}

void() SUB_Remove = {
	print("Removing");
	self.drawmask = 0;
	remove(self);
}

float() CS_W_FireRocket = 
{
    local float rocket_time = time;
    local entity rocket = spawn();

    setmodel(rocket, "progs/missile.mdl");

    makevectors(getviewprop(VF_ANGLES));	//set v_forward etc.            
    vector vieworg = getviewprop(VF_ORIGIN);

    setsize (rocket, '0 0 0', '0 0 0');
    setorigin (rocket, vieworg + v_forward*8 + '0 0 0');

    rocket.drawmask = MASK_ENGINE;
    rocket.predraw = RocketProject;
    rocket.starttime = rocket_time;
	rocket.movetype = MOVETYPE_FLYMISSILE;

    rocket.velocity = v_forward * 900;
    rocket.angles = vectoangles(rocket.velocity);
    rocket.source = rocket.origin;
	rocket.frame1time = 0.05;
	
	local float player_ping_s = getplayerkeyfloat(player_localnum, INFOKEY_P_PING) / 1000;

	rocket.think = SUB_Remove;

    sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);
    return rocket_time;
}