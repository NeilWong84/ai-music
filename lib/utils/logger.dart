import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// 应用日志服务
/// 
/// 提供统一的日志记录接口，支持：
/// - 多级别日志（Verbose, Debug, Info, Warning, Error）
/// - 美化控制台输出
/// - 文件持久化存储
/// - 日志过滤和配置
class AppLogger {
  static Logger? _logger;
  static File? _logFile;
  
  /// 获取Logger单例
  static Logger get instance {
    _logger ??= _createLogger();
    return _logger!;
  }
  
  /// 创建Logger实例
  static Logger _createLogger() {
    return Logger(
      printer: PrettyPrinter(
        methodCount: 2, // 显示调用栈层数
        errorMethodCount: 8, // 错误时显示更多栈信息
        lineLength: 120, // 每行字符数
        colors: true, // 彩色输出
        printEmojis: true, // 使用表情符号
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // 显示时间戳
      ),
      level: Level.debug, // 设置日志级别
    );
  }
  
  /// 初始化日志系统（包含文件输出）
  static Future<void> init() async {
    try {
      // 获取应用文档目录
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');
      
      // 创建日志目录
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }
      
      // 创建日志文件（按日期命名）
      final now = DateTime.now();
      final fileName = 'app_${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}.log';
      _logFile = File('${logDir.path}/$fileName');
      
      // 创建支持文件输出的Logger
      _logger = Logger(
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        ),
        output: MultiOutput([
          ConsoleOutput(), // 控制台输出
          FileOutput(file: _logFile!), // 文件输出
        ]),
        level: Level.debug,
      );
      
      instance.i('📝 日志系统初始化成功，日志文件: ${_logFile!.path}');
    } catch (e) {
      // 如果文件输出失败，回退到只输出到控制台
      _logger = _createLogger();
      instance.e('⚠️ 日志文件初始化失败，只使用控制台输出: $e');
    }
  }
  
  /// Verbose 级别日志（最详细）
  static void v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    instance.t(message, error: error, stackTrace: stackTrace);
  }
  
  /// Debug 级别日志（调试信息）
  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    instance.d(message, error: error, stackTrace: stackTrace);
  }
  
  /// Info 级别日志（一般信息）
  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    instance.i(message, error: error, stackTrace: stackTrace);
  }
  
  /// Warning 级别日志（警告）
  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    instance.w(message, error: error, stackTrace: stackTrace);
  }
  
  /// Error 级别日志（错误）
  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    instance.e(message, error: error, stackTrace: stackTrace);
  }
  
  /// Fatal 级别日志（致命错误）
  static void f(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    instance.f(message, error: error, stackTrace: stackTrace);
  }
  
  /// 获取日志文件路径
  static String? get logFilePath => _logFile?.path;
  
  /// 清理旧日志文件（保留最近7天）
  static Future<void> cleanOldLogs({int daysToKeep = 7}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');
      
      if (!await logDir.exists()) return;
      
      final now = DateTime.now();
      final files = logDir.listSync();
      
      for (var file in files) {
        if (file is File && file.path.endsWith('.log')) {
          final stat = await file.stat();
          final age = now.difference(stat.modified).inDays;
          
          if (age > daysToKeep) {
            await file.delete();
            instance.i('🗑️ 删除旧日志文件: ${file.path}');
          }
        }
      }
    } catch (e) {
      instance.e('清理旧日志失败: $e');
    }
  }
}

/// 文件输出类
class FileOutput extends LogOutput {
  final File file;
  
  FileOutput({required this.file});
  
  @override
  void output(OutputEvent event) {
    try {
      // 将日志写入文件（追加模式）
      final buffer = StringBuffer();
      for (var line in event.lines) {
        buffer.writeln(line);
      }
      file.writeAsStringSync(
        buffer.toString(),
        mode: FileMode.append,
        flush: true,
      );
    } catch (e) {
      // 文件写入失败时静默处理，避免影响应用运行
    }
  }
}

/// 多输出类
class MultiOutput extends LogOutput {
  final List<LogOutput> outputs;
  
  MultiOutput(this.outputs);
  
  @override
  void output(OutputEvent event) {
    for (var output in outputs) {
      try {
        output.output(event);
      } catch (e) {
        // 某个输出失败不影响其他输出
      }
    }
  }
}
