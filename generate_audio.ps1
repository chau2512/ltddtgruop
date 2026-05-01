Add-Type -AssemblyName System.Speech
$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
$synth.SetOutputToWaveFile('d:\matchquizapp\assets\audio\correct.mp3')
$synth.Speak('Correct')
$synth.SetOutputToWaveFile('d:\matchquizapp\assets\audio\wrong.mp3')
$synth.Speak('Wrong')
$synth.SetOutputToWaveFile('d:\matchquizapp\assets\audio\applause.mp3')
$synth.Speak('Congratulations, you win')
$synth.SetOutputToWaveFile('d:\matchquizapp\assets\audio\bgm.mp3')
$synth.Speak('Background music playing.')
$synth.Dispose()
