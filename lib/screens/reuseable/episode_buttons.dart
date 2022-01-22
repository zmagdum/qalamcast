
import 'package:flutter/material.dart';
import 'package:podcast_app/firestore_database_maanger/sqlite_manager.dart';
import 'package:podcast_app/models/podcast_data.dart';
import 'package:flutter_svg/svg.dart';
import 'package:podcast_app/utility/constants.dart';

import '../../downloader.dart';

class FavouriteEpisodeButton extends StatefulWidget {
  final Episode? episode;
  final double width;
  final double height;
  FavouriteEpisodeButton(this.episode, {this.width = 40.0, this.height = 40.0});

  @override
  _FavouriteEpisodeButtonState createState() => _FavouriteEpisodeButtonState();
}

class _FavouriteEpisodeButtonState extends State<FavouriteEpisodeButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: GestureDetector(
        onTap: () {
          // make episode favourite or unfavourite
          widget.episode!.isSelected = !widget.episode!.isSelected;

          SqliteDatabaseManager.shared.makeFavOrUnFavEpisode(widget.episode!);
          setState(() {});
        },
        child: Container(
          color: Colors.transparent,
          child: SvgPicture.asset(
              widget.episode!.isSelected ? Images.FAVORITE : Images.UNFAVORITE,
              // Images.FAVORITE,
              height: 40,
              width: 40),
        ),
      ),
    );
  }
}

class DownloadEpisodeButton extends StatefulWidget {
  final Episode? episode;
  DownloadEpisodeButton(this.episode);

  @override
  _DownloadEpisodeButtonState createState() => _DownloadEpisodeButtonState();
}

class _DownloadEpisodeButtonState extends State<DownloadEpisodeButton> {
  bool isDownloading = false;
  double downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 200)).then((value) {
      if (DownloadManager.shared.isDownloading(widget.episode)) {
        downloadEpisode();
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        downloadEpisode();
      },
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            SvgPicture.asset(
                widget.episode!.downloaded ? Images.CHECKED : Images.DOWNLOAD,
                height: 40,
                width: 40),
            if (isDownloading)
              Container(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(value: downloadProgress),
              ),
          ],
        ),
      ),
    );
  }


  downloadEpisode() {
    var episode = widget.episode!;
    if (episode.downloaded) {
      return;
    }
    setState(() {
      isDownloading = true;
    });
    var onProgress = (progress) {
      if (!this.mounted) {
        return;
      }
      setState(() {
        downloadProgress = progress;
      });
    };
    var onDownloadFinish = (file) {
      if (!this.mounted) {
        return;
      }
        setState(() {
          isDownloading = false;
          episode.downloaded = true;
        });
    };
    var onError = (e) {
      if (!this.mounted) {
        return;
      }

      setState(() {
        isDownloading = false;
      });
    };

    if (!DownloadManager.shared.isDownloading(episode)) {
      DownloadManager.shared.donwloadCourse(episode,
          onProgress: onProgress, onDone: onDownloadFinish, onError: onError);
    } else {
      var downloader = DownloadManager.shared.downloaderFor(episode)!;
      setState(() {
        downloadProgress = downloader.currentProgress;
      });
      DownloadManager.shared.addListners(
          episode, downloader, onProgress, onError, onDownloadFinish);
    }
  }
}
