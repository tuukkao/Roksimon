Roksimon
========

Audio-only Simon Says for the Rockbox platform.

## Description

Roksimon is a port of Simon Says for digital audio players running the Rockbox firmware. It has only been tested with the Sandisk Sansa Clip plus, but it may work with other players as well.

This version of Simon Says is inspired by Simon, a handheld game console from the late 1970's. Unlike the original, this game has no visuals whatsoever.

## Installation

Just copy roksimon.lua into your dap. No other installation is necessary.

## Playing the game

The idea of the game is to repeat a sequence of tones exactly in the order  it is played. The sequence gets longer with each successful round. The game ends when you hit a wrong tone.

When you launch the game you'll land on the preview screen. Here you can preview the tones that you'll have to repeat. Use the up, down, left and right buttons to listen to each of the tones. When you're ready to play, hit the select button, which is usually the center button on the navigation pad.

After hearing the tone sequence (which at first will be just one tone, then two and so forth), use the up, down, left and right buttons to repeat the tones exactly as you heard them. Only the order matters here; you can play the tones as slowly as you want.

The game ends on the first wrong tone. However, you do have one special trick at your disposal. You can press the home button to fill in the sequence for you. Note that you only get points for the tones you played right, so if you filled in the whole sequence, you'd get 0 points for that round. Also, you can fill in only once per 10 rounds.

You can adjust the volume of the tones any time by using the volume up and down keys on your player.

At the root of your player you'll find a file called roksimon_stats.txt. It contains information about every game of Roksimon you've played. Roksimon logs the date and time of the game, the number of successful rounds as well as the final score.

Heard two short, high-pitched tones you didn't recognise? That means you just made a new high score record.

## Author

Tuukka Ojala <tuukka.ojala@gmail.com>

## License

This work is licensed under the MIT license. See the file LICENSE for more information.