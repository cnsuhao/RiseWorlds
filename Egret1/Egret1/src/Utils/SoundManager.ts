/**
 *
 * 声音管理类
 * @author 
 *
 */
class SoundManager {
    private static sdbg: egret.Sound;
    private static sdbg_channel: egret.SoundChannel;
    
	/**播放音效*/
	public static playEffect(name:string,value:number=1){
    	  //判断音效按钮是否静音，是则return 否则播放
        var sound_eff: egret.Sound = RES.getRes(name);
        sound_eff.type = egret.Sound.EFFECT;
//        sound_eff.volume = value;
        var channel_eff: egret.SoundChannel = sound_eff.play(0, 1);
        channel_eff.volume = value;
	}
	
	/**播放背景音乐*/
    public static playBgSound(name:string,loop:boolean=true){
        this.sdbg=RES.getRes(name);
        this.sdbg.type = egret.Sound.MUSIC;
        this.sdbg_channel = this.sdbg.play(0, loop ? 0 : 1);
    }
    /**停止背景音乐*/
    public static stopBgSound(){
//        this.sdbg.stop();
        this.sdbg_channel.stop();
    }
    
    //判断音乐按钮是否静音，是则停止播放，否则恢复播放
    
	
}
