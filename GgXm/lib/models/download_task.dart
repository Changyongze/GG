enum DownloadStatus {
  pending,
  downloading,
  paused,
  completed,
  failed,
}

class DownloadTask {
  final String id;
  final String url;
  final String filename;
  final String savePath;
  final DownloadStatus status;
  final double progress;
  final String? error;
  final DateTime createdAt;
  final DateTime? completedAt;

  DownloadTask({
    required this.id,
    required this.url,
    required this.filename,
    required this.savePath,
    required this.status,
    this.progress = 0.0,
    this.error,
    required this.createdAt,
    this.completedAt,
  });

  bool get isCompleted => status == DownloadStatus.completed;
  bool get isFailed => status == DownloadStatus.failed;
  bool get isDownloading => status == DownloadStatus.downloading;
  bool get isPaused => status == DownloadStatus.paused;
  bool get isPending => status == DownloadStatus.pending;
} 