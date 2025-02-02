import 'package:audioplayers/audioplayers.dart';

class MusicaJuego {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> iniciarMusica() async {
    await _player.setReleaseMode(ReleaseMode.loop); // Para que haga loop
    await _player.play(
        AssetSource('audio/Brylie_Christopher_Oxley_-_Ethereal_Cafe.mp3'));
  }

  static Future<void> detenerMusica() async {
    await _player.stop();
  }

  static Future<void> iniciarMusicaWin() async {
    // Detenemos cualquier música previa antes de reproducir la música de victoria
    await _player.stop();
    await _player
        .play(AssetSource('audio/Mega_Man_(NES)_Music_-_Victory_Theme.mp3'));
  }

  static Future<void> iniciarMusicaDerrota() async {
    // Detenemos cualquier música previa antes de reproducir la música de victoria
    await _player.stop();
    await _player.play(AssetSource('audio/Monplaisir_-_Defeat.mp3'));
  }
}
