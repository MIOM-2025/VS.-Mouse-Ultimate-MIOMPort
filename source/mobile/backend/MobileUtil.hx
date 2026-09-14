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
* @version: 0.5.0
**/
typedef CustomStorageModeData = { modes:Array<ModeData> }
typedef ModeData = { Name:String, Folder:String }

class MobileUtil
{
	#if sys
	public static inline function getAssetDirectory():String
		return #if android haxe.io.Path.addTrailingSlash(getExternalDataPath())
		       #elseif ios lime.system.System.documentsDirectory
		       #else Sys.getCwd() #end;

	#if android
	/**
	 * 自动获取当前 app 的包名。
	 * 优先从 AndroidContext.getExternalFilesDir() 解析，
	 * 其次从 applicationStorageDirectory 解析，
	 * 最后回退到一个默认值。
	 */
	public static function getPackageName():String
	{
		// 1) 从 AndroidContext.getExternalFilesDir() 解析
		//    通常返回: /storage/emulated/0/Android/data/<pkg>/files
		try
		{
			var extDir = AndroidContext.getExternalFilesDir();
			if (extDir != null && extDir.length > 0)
			{
				var parts = extDir.replace("\\", "/").split("/");
				for (i in 0...parts.length)
				{
					if (parts[i] == "data" && i + 1 < parts.length && parts[i + 1].indexOf(".") != -1)
						return parts[i + 1];
				}
			}
		}
		catch (e:Dynamic) {}

		// 2) 从 applicationStorageDirectory 解析
		//    通常返回: /data/user/0/<pkg>/files/
		try
		{
			var appDir = LimeSystem.applicationStorageDirectory;
			if (appDir != null && appDir.length > 0)
			{
				var parts = appDir.replace("\\", "/").split("/")
					.filter(function(s) return s.length > 0);
				for (i in 0...parts.length)
				{
					if (parts[i] == "0" && i + 1 < parts.length && parts[i + 1].indexOf(".") != -1)
						return parts[i + 1];
				}
			}
		}
		catch (e:Dynamic) {}

		// 3) 兜底
		return "com.miom.vmuport";
	}

	/** /sdcard/Android/data/<pkg>/files */
	public static inline function getExternalDataPath():String
		return '/sdcard/Android/data/${getPackageName()}/files';

	/** /sdcard/Android/media/<pkg> */
	public static inline function getExternalMediaPath():String
		return '/sdcard/Android/media/${getPackageName()}';

	/** /sdcard/Android/obb/<pkg> */
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
							// Keeping the "Name|Folder" format, so initDirectory() doesn't break
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

	// always force path due to haxe
	public static var currentDirectory:String;
	public static function initDirectory():String {
		var daPath:String = '';
		if (!FileSystem.exists(getStorageTypePath()))
			File.saveContent(getStorageTypePath(), Options.storageType);

		var curStorageType:String = File.getContent(getStorageTypePath());

		/* Put this there because I don't want to override original paths, also brokes the normal storage system */
		for (line in getCustomStorageDirectories(true))
		{
			if (line.startsWith(curStorageType) && (line != '' || line != null)) {
				var dat = line.split("|");
				daPath = dat[1];
			}
		}

		/* Hardcoded Storage Types, these types cannot be changed by Custom Type
		 * paths using "/sdcard/" location because otherwise engine crashes. -ArkoseLabs
		 **/
		switch(curStorageType) {
			case 'EXTERNAL':
				daPath = "/sdcard/.CodenameEngine";
			/* obb doesnt work and I dont wanna fix it -ArkoseLabs
			case 'EXTERNAL_OBB':
				daPath = getExternalObbPath();
			*/
			case 'EXTERNAL_MEDIA':
				daPath = getExternalMediaPath();
			case 'EXTERNAL_DATA':
				daPath = getExternalDataPath();
			default: //technically not needed but here for safety -ArkoseLabs
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
			//lime.system.System.exit(1);
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
			//lime.system.System.exit(1);
		}

		return daPath;
	}

	/**
	 * Requests Storage Permissions on Android Platform.
	 */
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
	 * Saves a file to the external storage.
	 */
	public static function save(fileName:String = 'Ye', fileExt:String = '.txt', fileData:String = 'Nice try, but you failed, try again!', ?alert:Bool = true):Void
	{
		final folder:String = #if android MobileUtil.getDirectory() + #else Sys.getCwd() + #end 'saves/';
		try
		{
			if (!FileSystem.exists(folder))
				FileSystem.createDirectory(folder);

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
	 * 复制 / 解压资源到外部存储。
	 *
	 * 默认行为（folders == null）：
	 *   强制解压 "assets/" 与 "mods/" 前缀下的所有文件，
	 *   命中即覆盖，不做字节比对。
	 *
	 * 显式传入 folders 时，仅按传入的前缀过滤，
	 *   并且依然执行"强制覆盖"（本方法整体语义就是强制解压）。
	 *
	 * @param folders     可选，指定要解压的目录前缀列表（如 ["assets/data/"]）。
	 * @param onProgress  进度回调 (relativePath, current, total)。
	 * @param onComplete  完成回调。
	 */
	public static function copyAssets(folders:Array<String> = null, onProgress:String->Int->Int->Void = null, onComplete:Void->Void = null):Void {
		#if mobile
		var rootTarget = getAssetDirectory();
		try {
			var assetList:Array<String> = Assets.list();

			// 默认强制解压的前缀（顶层 mods/ 与 assets/ 都会被命中，
			// 所以 assets/assets/、assets/mods/ 都在范围内）
			var forcePrefixes:Array<String> = ["assets/", "mods/"];

			var toCopy = assetList.filter(function(assetKey) {
				var cleanPath = assetKey;
				var colonIndex = cleanPath.indexOf(":");
				if (colonIndex != -1) cleanPath = cleanPath.substring(colonIndex + 1);

				// 显式传入 folders 时，按传入的前缀来
				if (folders != null) {
					for (f in folders) {
						if (StringTools.startsWith(cleanPath, f)) return true;
					}
					return false;
				}

				// 否则默认：强制解压 assets/ 与 mods/
				for (p in forcePrefixes) {
					if (StringTools.startsWith(cleanPath, p)) return true;
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

				var directory = Path.directory(fullPath);
				if (!FileSystem.exists(directory)) FileSystem.createDirectory(directory);

				// 强制解压：直接覆盖，不做 size / byte 比对
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
		}
		#end
	}
}