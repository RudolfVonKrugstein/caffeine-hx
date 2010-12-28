package chx.log.flash;
import chx.io.StringOutput;
import chx.log.BaseLogger;
import chx.log.IEventLog;
import chx.log.LogFormat;
import chx.log.LogLevel;
import flash.text.TextField;
import flash.text.TextFormat;
import haxe.PosInfos;

/**
 * ...
 * @author Russell Weir
 */

class TextFieldLogger extends BaseLogger, implements IEventLog
{
	/** the default format for Syslog type loggers */
	public static var defaultFormat : LogFormat = new LogFormat(LogFormat.formatShort);
	static var defTextFont		: String = "_sans"; // "Times New Roman"
	static var defTextFontSize	: Int = 12;
	
	public var textFormatDebug : TextFormat;
	public var textFormatInfo : TextFormat;
	public var textFormatNotice : TextFormat;
	public var textFormatWarn : TextFormat;
	public var textFormatError : TextFormat;
	public var textFormatCritical : TextFormat;
	public var textFormatAlert : TextFormat;
	public var textFormatEmerge : TextFormat;
	
	public var textField : TextField;
	
	public function new(textField:TextField, service: String, ?level:LogLevel) {
		super(service, level);
		this.textField = textField;
		this.format = defaultFormat.clone();
		this.textFormatDebug = makeFont(defTextFont, defTextFontSize, 0x000000);
		this.textFormatInfo = makeFont(defTextFont, defTextFontSize, 0x000053);
		this.textFormatNotice = makeFont(defTextFont, defTextFontSize, 0x5b6308);
		this.textFormatWarn = makeFont(defTextFont, defTextFontSize, 0x63172e);
		this.textFormatError = makeFont(defTextFont, defTextFontSize, 0xc00f0f);
		this.textFormatCritical = makeFont(defTextFont, defTextFontSize, 0xc009ba);
		this.textFormatAlert = makeFont(defTextFont, defTextFontSize, 0xff0000);
		this.textFormatEmerge = makeFont(defTextFont, defTextFontSize, 0xff0000);
		
		this.textFormatAlert.italic = true;
		
		this.textFormatEmerge.italic = true;
		this.textFormatEmerge.underline = true;
	}
	
	private function makeFont(fontName:String, fontSize:Int, color:UInt) {
		var f : TextFormat = new TextFormat();
		f.font = fontName;
		f.size = fontSize;
		f.color = color;
		return f;
	}
	override public function log(s:String, ?lvl:LogLevel, ?pos:PosInfos) {
		if (this.textField == null) return;
		if(Type.enumIndex(lvl) >= Type.enumIndex(level)) {
			var tf : TextFormat = switch(lvl) {
			case DEBUG: textFormatDebug;
			case INFO: textFormatInfo;
			case NOTICE: textFormatNotice;
			case WARN: textFormatWarn;
			case ERROR: textFormatError;
			case CRITICAL: textFormatCritical;
			case ALERT: textFormatAlert;
			case EMERG: textFormatEmerge;
			}
			var so : StringOutput = new StringOutput();
			format.writeLogMessage(so, this.serviceName, lvl, s, pos);
			//textField.setTextFormat(tf);
			textField.defaultTextFormat = tf;
			textField.appendText(so.toString()+"\n");
		}
	}
	
}