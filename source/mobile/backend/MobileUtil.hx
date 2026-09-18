package mobile.backend;

import lime.system.System as LimeSystem;
import haxe.io.Path;
import haxe.Exception;

import lime.system.System;
import lime.app.Application;
import openfl.Assets;
import haxe.io.Bytes;
#if sys
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#end

using StringTools;

/** 
* @Authors MaysLastPlay, ArkoseLabs, MarioMaster (MasterX-39), Dechis (dx7405)
* @version: 0.4.3
**/
typedef CustomStorageModeData = { modes:Array<ModeData> }
typedef ModeData = { Name:String, Folder:String }
class MobileUtil
{
	#if sys
	public static inline function getAssetDirectory():String
		return #if android haxe.io.Path.addTrailingSlash(getExternalDataPath()) #elseif ios lime.system.System.documentsDirectory #else Sys.getCwd() #end;

	#if android
	/**
	 * 自动从 AndroidContext.getExternalFilesDir() 反推当前包名。
	 * 路径固定格式: /storage/emulated/0/Android/data/<包名>/files
	 */
	public static function getPackageName():String
	{
		try {
			var extDir = AndroidContext.getExternalFilesDir();
			if (extDir != null && extDir.length > 0) {
				var parts = extDir.replace("\\", "/").split("/");
				for (i in 0...parts.length) {
					if (parts[i] == "data" && i + 1 < parts.length && parts[i + 1].indexOf(".") != -1)
						return parts[i + 1];
				}
			}
		} catch (e:Dynamic) {
			trace("Failed to auto-detect package name: " + e);
		}
		return "com.miom.vmuport";
	}

	public static inline function getExternalDataPath():String
		return '/sdcard/Android/data/${getPackageName()}/files';

	public static inline function getExternalMediaPath():String
		return '/sdcard/Android/media/${getPackageName()}';

	public static inline function getExternalObbPath():String
		return '/sdcard/Android/obb/${getPackageName()}';

	public static inline function getCustomStoragePath():String
		return AndroidContext.getExternalFilesDir() + '/storageModes.json';
	public static inline function getStorageTypePath():String
		return AndroidContext.getExternalFilesDir() + '/storagetype.txt';

	public static function getCustomStorageDirectories(?doNotSeperate:Bool):Array<String>
	{
		var curJsonFile:String = getCustomStoragePath();
		var ArrayReturn:Array<String> = [];

		if (FileSystem.exists(curJsonFile))
		{
			try {
				var rawJson:String = File.getContent(curJsonFile);
				var parsedData:CustomStorageModeData = haxe.Json.parse(rawJson);

				if (parsedData.modes != null) {
					for (mode in parsedData.modes) {
						if (mode.Name == null || mode.Folder == null) continue;

						if (doNotSeperate)
							ArrayReturn.push(mode.Name + "|" + mode.Folder);
						else
							ArrayReturn.push(mode.Name);
					}
				}
			} catch (e:haxe.Exception) {
				trace("Error parsing storage JSON: " + e.message);
			}
		}
		return ArrayReturn;
	}

	public static var currentDirectory:String;
	public static function initDirectory():String {
		var daPath:String = '';
		if (!FileSystem.exists(getStorageTypePath()))
			File.saveContent(getStorageTypePath(), Options.storageType);

		var curStorageType:String = File.getContent(getStorageTypePath());

		for (line in getCustomStorageDirectories(true))
		{
			if (line.startsWith(curStorageType) && (line != '' || line != null)) {
				var dat = line.split("|");
				if (dat.length >= 2) daPath = dat[1];
			}
		}

		switch(curStorageType) {
			case 'EXTERNAL':
				daPath = "/sdcard/.CodenameEngine";
			/*
			case 'EXTERNAL_OBB':
				daPath = getExternalObbPath();
			*/
			case 'EXTERNAL_MEDIA':
				daPath = getExternalMediaPath();
			case 'EXTERNAL_DATA':
				daPath = getExternalDataPath();
			default:
				if (daPath == null || daPath == '') daPath = getExternalDataPath();
		}
		daPath = Path.addTrailingSlash(daPath);
		currentDirectory = daPath;

		try
		{
			if (!FileSystem.exists(MobileUtil.getAssetDirectory()))
				FileSystem.createDirectory(MobileUtil.getAssetDirectory());
		}
		catch (e:Dynamic)
		{
			Application.current.window.alert("Looks like you doesn't have directory named\n" + MobileUtil.getAssetDirectory() +
			"\nBut maybe this couldn't be right, android loves to give errors like this\nPress OK & let's see what happens\nCurrent Error You Got:\n" + e, "Warning!");
		}

		try
		{
			if (!FileSystem.exists(MobileUtil.getDirectory() + "mods/"))
				FileSystem.createDirectory(MobileUtil.getDirectory() + "mods/");
		}
		catch (e:Dynamic)
		{
			Application.current.window.alert("Looks like you doesn't have directory named\n" + MobileUtil.getDirectory() + "mods/" + 
			"\nBut maybe this couldn't be right, android loves to give errors like this\nPress OK & let's see what happens\nCurrent Error You Got:\n" + e, "Warning!");
		}

		return daPath;
	}

	public static function getPermissions():Void
	{
		if (AndroidVersion.SDK_INT >= AndroidVersionCode.TIRAMISU)
			AndroidPermissions.requestPermissions([
				'READ_MEDIA_IMAGES',
				'READ_MEDIA_VIDEO',
				'READ_MEDIA_AUDIO',
				'READ_MEDIA_VISUAL_USER_SELECTED'
			]);
		else
			AndroidPermissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);

		if (!AndroidEnvironment.isExternalStorageManager())
			AndroidSettings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
	}

	public static var lastGettedPermission:Int;
	public static function chmodPermission(fullPath:String) {
		var process = new Process('stat -c %a ${fullPath}');
		var stringOutput:String = process.stdout.readAll().toString();
		process.close();
		lastGettedPermission = Std.parseInt(stringOutput);
	}

	public static function chmod(permissions:Int, fullPath:String) {
		var process = new Process('chmod -R ${permissions} ${fullPath}');

		var exitCode = process.exitCode();
		if (exitCode == 0) 
			trace('Success: Permissions for the ${fullPath} file have been set to (${permissions})');
		else
		{
			var errorOutput = process.stderr.readAll().toString();
			trace('ERROR: Request to change permissions for the (${fullPath}) file failed. Exit Code: ${exitCode}, Error: ${errorOutput}');
		}
		process.close();
	}
	#end

	public static function getDirectory():String
	{
		#if android	
		var _currentDirectory = currentDirectory;
		if (_currentDirectory == null || _currentDirectory == "") {
    	    trace("currentDirectory is null, initializing again...");
    	    _currentDirectory = initDirectory(); 
    	}
		return _currentDirectory;
		#elseif ios
		return LimeSystem.documentsDirectory;
		#else
		return Sys.getCwd();
		#end
	}

	/**
	 * 递归创建目录，避免 HXCPP 后端 FileSystem.createDirectory 行为不一致。
	 */
	public static function mkdirs(path:String):Void
	{
		#if sys
		if (path == null || path == "" || path == "/") return;
		while (path.length > 1 && (path.endsWith("/") || path.endsWith("\\")))
			path = path.substr(0, path.length - 1);
		if (FileSystem.exists(path)) return;
		mkdirs(Path.directory(path));
		try {
			FileSystem.createDirectory(path);
		} catch (e:Dynamic) {
			if (!FileSystem.exists(path)) trace('mkdirs failed for $path: $e');
		}
		#end
	}

	/**
	 * Saves a file to the external storage.
	 */
	public static function save(fileName:String = 'Ye', fileExt:String = '.txt', fileData:String = 'Nice try, but you failed, try again!', ?alert:Bool = true):Void
	{
		final folder:String = #if android MobileUtil.getDirectory() + #else Sys.getCwd() + #end 'saves/';
		try
		{
			mkdirs(folder);
			File.saveContent('$folder/$fileName', fileData);
			if (alert)
				Application.current.window.alert('${fileName} has been saved.', "Success!");
		}
		catch (e:Dynamic)
			if (alert)
				Application.current.window.alert('${fileName} couldn\'t be saved.\n${e.message}', "Error!");
			else
				trace('$fileName couldn\'t be saved. (${e.message})');
	}
	#end

	/**
	 * 同步强制解压 assets/ 与 mods/ 全部文件。
	 * 注意：会阻塞主线程，UI 不会刷新。要显示进度请用 copyAssetsAsync()。
	 */
	public static function copyAssets(folders:Array<String> = null, onProgress:String->Int->Int->Void = null, onComplete:Void->Void = null):Void {
		#if mobile
		var rootTarget = getAssetDirectory();
		try {
			var assetList:Array<String> = Assets.list();

			var toCopy = assetList.filter(function(assetKey) {
				var cleanPath = assetKey;
				var colonIndex = cleanPath.indexOf(":");
				if (colonIndex != -1) cleanPath = cleanPath.substring(colonIndex + 1);

				var defaultRoots:Array<String> = ["assets/", "mods/"];

				if (folders != null) {
					for (f in folders) {
						if (StringTools.startsWith(cleanPath, f)) return true;
					}
					return false;
				}

				for (root in defaultRoots) {
					if (StringTools.startsWith(cleanPath, root)) return true;
				}
				return false;
			});

			var total = toCopy.length;
			if (total == 0) {
				if (onComplete != null) onComplete();
				return;
			}

			for (i in 0...total) {
				var assetKey = toCopy[i];

				var cleanPath = assetKey;
				var colonIndex = cleanPath.indexOf(":");
				if (colonIndex != -1) cleanPath = cleanPath.substring(colonIndex + 1);

				var fullPath = Path.join([rootTarget, cleanPath]);

				mkdirs(Path.directory(fullPath));

				var bytes:Bytes = null;
				try {
					bytes = Assets.getBytes(assetKey);
				} catch (e:Dynamic) {
					try {
						var text:String = Assets.getText(assetKey);
						if (text != null) bytes = Bytes.ofString(text);
					} catch (e2:Dynamic) {
						trace('Failed to read text fallback for $assetKey: $e2');
					}
				}

				if (bytes != null) {
					File.saveBytes(fullPath, bytes);
				} else {
					trace('Could not extract data for asset: $assetKey');
				}

				if (onProgress != null) onProgress(cleanPath, i + 1, total);
			}

			if (onComplete != null) onComplete();
		} catch (e:Dynamic) {
			trace('Asset Copy Error: $e');
			if (onComplete != null) onComplete();
		}
		#end
	}

	#if mobile
	/**
	 * 分帧异步解压 assets/ 与 mods/ 到外部存储。
	 *
	 * - 每帧复制 batchSize 个文件，让出主线程，UI 可正常刷新。
	 * - onProgress(relativePath, copied, total) 每帧回调一次。
	 * - onComplete() 全部完成后回调一次。
	 * - 全部完成时自动从 Application.current.onUpdate 移除自身。
	 *
	 * @param onProgress 进度回调（第二、三个参数为已复制数 / 总数）
	 * @param onComplete 完成回调
	 * @param batchSize  每帧处理文件数（默认 5，越大越快但越卡）
	 * @param folders    可选前缀列表，null 则默认 ["assets/", "mods/"]
	 */
	public static function copyAssetsAsync(
		onProgress:String->Int->Int->Void = null,
		onComplete:Void->Void = null,
		batchSize:Int = 5,
		folders:Array<String> = null
	):Void {
		var rootTarget = getAssetDirectory();
		var toCopy:Array<{key:String, rel:String}> = [];

		// === 1. 收集要复制的文件（很快） ===
		try {
			var assetList:Array<String> = Assets.list();
			var defaultRoots:Array<String> = ["assets/", "mods/"];

			for (assetKey in assetList) {
				var cleanPath = assetKey;
				var colonIndex = cleanPath.indexOf(":");
				if (colonIndex != -1) cleanPath = cleanPath.substring(colonIndex + 1);

				var hit = false;
				if (folders != null) {
					for (f in folders) {
						if (StringTools.startsWith(cleanPath, f)) { hit = true; break; }
					}
				} else {
					for (root in defaultRoots) {
						if (StringTools.startsWith(cleanPath, root)) { hit = true; break; }
					}
				}
				if (hit) toCopy.push({key: assetKey, rel: cleanPath});
			}
		} catch (e:Dynamic) {
			trace("copyAssetsAsync: Assets.list failed: " + e);
			if (onComplete != null) onComplete();
			return;
		}

		var total = toCopy.length;
		trace('[MobileUtil] copyAssetsAsync: $total files to copy');
		if (total == 0) {
			if (onComplete != null) onComplete();
			return;
		}

		var index = 0;
		var step:Int->Void = null;
		step = function(delta:Int) {
			var count = 0;
			while (index < total && count < batchSize) {
				var entry = toCopy[index];
				var fullPath = Path.join([rootTarget, entry.rel]);

				mkdirs(Path.directory(fullPath));

				// 强制覆盖
				var bytes:Bytes = null;
				try {
					bytes = Assets.getBytes(entry.key);
				} catch (e:Dynamic) {
					try {
						var text:String = Assets.getText(entry.key);
						if (text != null) bytes = Bytes.ofString(text);
					} catch (e2:Dynamic) {
						trace('Failed to read text fallback for ${entry.key}: $e2');
					}
				}

				if (bytes != null) {
					try {
						File.saveBytes(fullPath, bytes);
					} catch (e:Dynamic) {
						trace('save failed: $fullPath -> $e');
					}
				} else {
					trace('Could not extract data for asset: ${entry.key}');
				}

				index++;
				count++;
			}

			if (onProgress != null) {
				var lastPath = (index > 0) ? toCopy[index - 1].rel : "";
				onProgress(lastPath, index, total);
			}

			if (index >= total) {
				Application.current.onUpdate.remove(step);
				if (onComplete != null) onComplete();
			}
		};

		Application.current.onUpdate.add(step);
	}
	#end
}