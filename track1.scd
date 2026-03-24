// Boot the server
s.boot;

// Wait for server to be ready, then play a sine wave
s.waitForBoot({
    var bpm = 130;
    var barDur = 4 * 60 / bpm;  // duration of 1 bar in seconds

    SynthDef(\kick808, {
            arg freq = 40, amp =0.5;

            var pitchEnv = EnvGen.kr(Env([120, 40], [0.025], [\exp]));

            var body = SinOsc.ar(pitchEnv, 0, 0.5);

            var click = WhiteNoise.ar(0.2) * EnvGen.kr(Env.perc(0.001, 0.008));

            var sig = (body + click).tanh;

            var env = EnvGen.kr(Env.perc(0.005, 0.8), doneAction: 2);

            sig = sig * env;

            Out.ar(0, sig ! 2);


        }).add;
        
        SynthDef(\snare, {
            var body = SinOsc.ar(200, 0,0.3) * EnvGen.kr(Env.perc(0.005, 0.1));

            var noise = HPF.ar(WhiteNoise.ar(0.3), 1000) * EnvGen.kr(Env.perc(0.005, 0.15));

            var sig = (body + noise) * EnvGen.kr(Env.perc(0.005, 0.2), doneAction: 2);

            Out.ar(0, sig * 0.4 ! 2);
        }).add;

        SynthDef(\bass, {
            arg freq = 55, amp = 0.3, dur = 0.5;
            var env = EnvGen.kr(Env.perc(0.01, dur), doneAction: 2);
            var sig = SinOsc.ar(freq, 0, amp) + SinOsc.ar(freq * 2, 0, amp * 0.3);
            sig = sig.tanh;
            Out.ar(0, (sig * env) ! 2);
        }).add;

        SynthDef(\lead, {
            arg freq = 440, amp = 0.15, dur = 0.3;
            var env = EnvGen.kr(Env.perc(0.01, dur), doneAction: 2);
            var vibrato = SinOsc.kr(5, 0, 3);
            var bend = EnvGen.kr(Env([freq * 0.97, freq], [0.08], [\exp]));
            var sig = Saw.ar(bend + vibrato, amp);
            sig = LPF.ar(sig, freq * 3);
            sig = FreeVerb.ar(sig, 0.4, 0.6);
            Out.ar(0, (sig * env) ! 2);
        }).add;

        SynthDef(\pad, {
            arg freq = 220, amp = 0.08, dur = 4;
            var env = EnvGen.kr(Env.linen(0.5, dur - 1, 0.5), doneAction: 2);
            var sig = Saw.ar(freq * [0.99, 1, 1.01], amp);
            sig = Mix(sig);
            sig = LPF.ar(sig, 1500);
            sig = FreeVerb.ar(sig, 0.7, 0.9);
            Out.ar(0, sig ! 2);
        }).add;

        SynthDef(\hat, {
            var sig = HPF.ar(WhiteNoise.ar(0.2), 8000);
            var env = EnvGen.kr(Env.perc(0.005, 0.08), doneAction: 2);
            Out.ar(0, (sig * env) ! 2);
        }).add;

        s.sync;

        // Start recording
        s.record(path: "/home/dan/supercollider/track.wav");
        0.5.wait;  // small buffer before music starts

        TempoClock.default.tempo = bpm/60;

        // === INTRO: Bars 1-2 — kick + hats + bass ===
        ">> Kick + hats + bass".postln;
        ~kick = Pbind(\instrument, \kick808, \dur, 1, \freq, 40, \amp, 0.5).play;
        ~hat = Pbind(\instrument, \hat, \dur, 0.5).play;
        ~bass = Pbind(\instrument, \bass,
            \midinote, Pseq([36, 36, 39, 34], inf),
            \dur, Pseq([1, 0.5, 0.5, 2], inf),
            \amp, 0.3,
        ).play;
        (barDur * 2).wait;  // 2 bars

        // === BUILD: Bars 3-4 — snare enters ===
        ">> Snare enters".postln;
        ~snare = Pbind(\instrument, \snare, \dur, Pseq([Rest(1), 1], inf)).play;
        (barDur * 2).wait;  // 2 bars

        // === DROP: Bars 5-12 — lead + pad, full track ===
        ">> Full drop!".postln;
        ~lead = Pbind(\instrument, \lead,
            \midinote, Pseq([
                Pseq([60, 63, 58, 60, 65, 63, 60, 58], 2),
                Pseq([63, 65, 67, 63, 60, 58, 55, 58], 2),
            ], inf),
            \dur, Pseq([
                Pseq([0.5, 0.5, 1, 0.5, 0.5, 0.5, 0.5, 1], 2),
                Pseq([0.5, 0.5, 0.5, 1, 0.5, 0.5, 1, 0.5], 2),
            ], inf),
            \amp, 0.15,
        ).play;
        ~pad = Pbind(\instrument, \pad,
            \midinote, Pseq([48, 46, 43, 46], inf),
            \dur, 4, \amp, 0.02,
        ).play;
        (barDur * 8).wait;  // 8 bars

        // === BREAKDOWN: Bars 13-16 — pad + lead only ===
        ">> Breakdown".postln;
        ~kick.stop; ~snare.stop; ~hat.stop; ~bass.stop;
        (barDur * 4).wait;  // 4 bars

        // === DROP 2: Bars 17-28 — everything back ===
        ">> Drop 2!".postln;
        Pbind(\instrument, \kick808, \dur, 1, \freq, 40, \amp, 0.5).play;
        Pbind(\instrument, \hat, \dur, 0.5).play;
        Pbind(\instrument, \bass,
            \midinote, Pseq([36, 36, 39, 34], inf),
            \dur, Pseq([1, 0.5, 0.5, 2], inf),
            \amp, 0.3,
        ).play;
        Pbind(\instrument, \snare, \dur, Pseq([Rest(1), 1], inf)).play;
        (barDur * 12).wait;  // 12 bars

        // === OUTRO: Bars 29-32 — fade out ===
        ">> Outro".postln;
        ~lead.stop;
        (barDur * 4).wait;  // 4 bars

        // Let tails ring
        2.wait;

        // Stop recording
        s.stopRecording;
        1.wait;
        "Recording saved!".postln;

        0.exit;

 });
