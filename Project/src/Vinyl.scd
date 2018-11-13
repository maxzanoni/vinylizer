
~song = Buffer.read(s,thisProcess.nowExecutingPath.dirname +/+ "test2.wav");


// Audio Source
(
 SynthDef(\s1,
	{
		arg bufnum = 0, freqfilter = 1000;    // Number of the buffer to play
		var player,imp;

		player = PlayBuf.ar(1, bufnum, 1, doneAction:0);

		b = BLowPass.ar(player,freq:freqfilter, rq:1);

		Out.ar(0, Pan2.ar(b*0.7,0));
 }).add;
)

thisProcess.nowExecutingPath.dirname


// Dust
(
 SynthDef(\dust,
	{

		arg noiseIntensity =1, gainDust=1;
		var sig;

		sig = Crackle.ar(1.9, 0.005);
		sig = sig + HPF.ar(BrownNoise.ar(0.003*noiseIntensity/3),2000);
		sig = sig + LPF.ar(Dust.ar(1*noiseIntensity),600);
		sig = sig +  BPF.ar(0.8*Dust.ar(1*noiseIntensity),1000,0.5);

		sig = sig*gainDust;

		Out.ar(0, Pan2.ar(sig,0));
 }).add;
)


(
var w,slid2d, synth, gainDustKnob, effect, filterKnob, noiseIntKnob, audioview,g, g1, frequencyScope,v, volumeSlid;

w = Window("My Window", Rect(100,300,700,450));
w.background_(Color.new255(50, 50, 50));

v = Volume(s,0);

gainDustKnob  = EZKnob(w,Rect(5,5,150,150),"vintage",initVal:1);
gainDustKnob.setColors(Color.grey,Color.white,Color.grey,Color.white, Color.yellow,nil,nil, Color.grey(0.7));

g = ControlSpec.new(1, 10, \lin);
noiseIntKnob  = EZKnob(w,Rect(155,5,150,150),"intensity",g,initVal:1);
noiseIntKnob.setColors(Color.grey,Color.white,Color.grey,Color.white, Color.yellow,nil,nil, Color.grey(0.7));
filterKnob  = EZKnob(w,Rect(390,5,150,150),"filter",\freq,initVal:2500);
filterKnob.setColors(Color.grey,Color.white,Color.grey,Color.white, Color.yellow,nil,nil, Color.grey(0.7));
frequencyScope = FreqScopeView(w, Rect(5,200,500,200));

g1 = ControlSpec(0.ampdb, 4.ampdb, \db, units: " dB");
volumeSlid = EZSlider(w,Rect(600, 5, 60, 430),"Volume",g1,initVal:0,layout:\vert);
volumeSlid.setColors(Color.grey,Color.white,Color.grey,Color.white, Color.yellow,nil,nil, Color.grey(0.7));

volumeSlid.action_({
	v.volume = volumeSlid.value;
});

// Synth definition
synth = Synth(\s1,[\bufnum, ~song.bufnum, \freqfilter, 2500]);

filterKnob.action_({
	synth.set(\freqfilter,filterKnob.value);
});


// Effect Definition
effect = Synth(\dust,[\noiseIntensity, 1,\gainDust,1]);

gainDustKnob.action_({
	effect.set(\gainDust,gainDustKnob.value);
});

noiseIntKnob.action_({
	effect.set(\noiseIntensity,noiseIntKnob.value);
});

// Frequency Scope
frequencyScope.freqMode_(1); // change to log scale so we can see them
frequencyScope.inBus_(0); // look at bus 1
frequencyScope.background_(Color.new255(50, 50, 50));
frequencyScope.active_(false); // turn scope off (watch CPU)
frequencyScope.active_(true); // turn it back on

w.front;
w.onClose={synth.free; effect.free;};     	//action which stops running synth when the window close button is pressed
)