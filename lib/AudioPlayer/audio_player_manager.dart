import 'package:audioplayers/audioplayers.dart';
import 'package:podcast_app/models/podcast_data.dart';
import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';

Future<void> setupServiceLocator() async {
  // services
  GetIt.I.registerSingleton<AudioHandler>(await initAudioService());
}

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => BackgroundAudioHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.podcast.app.audio',
      androidNotificationChannelName: 'Podcast App',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class BackgroundAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  // The most common callbacks:
  Future<void> play() async {
    // All 'play' requests from all origins route to here. Implement this
    // callback to start playing audio appropriate to your app. e.g. music.
        MediaPlayer.shared.togglePlaying();

  }
  Future<void> pause() async {
    MediaPlayer.shared.togglePlaying();
  }
  Future<void> stop() async {}
  Future<void> seek(Duration position) async {
    MediaPlayer.shared.seekAtsliderValue(position.inSeconds.toDouble());
  }
  Future<void> skipToQueueItem(int i) async {
    // MediaPlayer.shared.pl
  }
}

abstract class PlaylistRepository {
  List<Map<String, String>> fetchInitialPlaylist();
  Future<Map<String, String>> fetchAnotherSong();
}

class MediaPlayer extends PlaylistRepository {
  @override
  List<Map<String, String>> fetchInitialPlaylist()  {
    return episodes?.map((e) => e.mediaItem())?.toList() ?? [];
  }

  @override
  Future<Map<String, String>> fetchAnotherSong() async {
    await playNext();
    return currentPlayingEpisode?.mediaItem() ?? Map();
  }

  static MediaPlayer shared = MediaPlayer();

  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;

  List<Episode>? episodes = [];
  Episode? currentPlayingEpisode;
  var currenItemIndex = 0;

  addListners({Function? onProgress, Function? onComplete, Function? onError}) {
    audioPlayer.onAudioPositionChanged.listen((duration) async {
      // print(duration);
      var totalDuration = await audioPlayer.getDuration();
      var progress = duration.inMilliseconds / totalDuration;
      // print(progress);

      onProgress!(progress, mediaPlayerTimeString(duration.inSeconds),
          mediaPlayerTimeString((totalDuration ~/ 1000).toInt()));
    });

    audioPlayer.onPlayerCompletion.listen((event) {
      playNext();
      onComplete!();
    });

    audioPlayer.onPlayerError.listen((error) {
      isPlaying = false;
      onError!(error);
    });
  }

  play({required Episode episode, bool isLocal = false}) async {
    if (episode.id == this.currentPlayingEpisode?.id) {
      if (isPlaying) {
        return;
      }
    } else {
      audioPlayer.stop();
    }
    audioPlayer.play(episode.streamUrl!).then((result) async {
      this.currentPlayingEpisode = episode;
      if (result == 1) {
        var totalDuration = await audioPlayer.getDuration();
        print(totalDuration);
        isPlaying = true;
      }
    });
  }

  togglePlaying({bool forcePause = false}) {
    if (isPlaying || forcePause) {
      audioPlayer.pause();
    } else {
      audioPlayer.resume();
    }
    isPlaying = !isPlaying;
  }

  toggleSeek({bool isBackSeek = false}) async {
    var duration = await audioPlayer.getCurrentPosition();

    if (isBackSeek) {
      duration = duration - (10 * 1000); // duration in miliseconds
    } else {
      duration = duration + (10 * 1000);
    }

    seekPlayer(duration);
  }

  seekAtsliderValue(double value) async {
    var duration = await audioPlayer.getDuration();
    var position = duration * value;
    seekPlayer(position.toInt());
  }

  seekPlayer(int position) {
    audioPlayer.seek(Duration(milliseconds: position));
  }

  playNext() async {
    var nextIndex = currenItemIndex + 1;
    if (episodes!.length > nextIndex) {
      await audioPlayer.pause();
      var nextEpisode = episodes![nextIndex];
      currenItemIndex = nextIndex;
      play(episode: nextEpisode, isLocal: nextEpisode.downloaded);
    }
  }

  playPreviouse() async {
    var preIndex = currenItemIndex - 1;
    if (preIndex >= 0 && episodes!.length > preIndex) {
      await audioPlayer.pause();

      var nextEpisode = episodes![preIndex];
      currenItemIndex = preIndex;
      play(episode: nextEpisode, isLocal: nextEpisode.downloaded);
    }
  }

  String mediaPlayerTimeString(int duration) {
    var totalSeconds = duration;
    if (totalSeconds.isNaN) return "00:00";
    var d = Duration(seconds: totalSeconds);
    List<String> parts = d.toString().split(':');
    var seconds = double.parse(parts[2]);
    var time =
        '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}:${seconds.toInt().toString().padLeft(2, '0')}';
    return time;
  }
}

extension MediaItem on Episode {
  Map<String, String> mediaItem() {
    return {
      'id': this.id ?? "",
      'title': this.title ?? "",
      'album': this.shortTitle ?? "",
      'url': (this.downloaded ? this.downloadFilePath : this.streamUrl) ?? ""
    };
  }
}
