/**
 *
 * 炮塔01
 * @author 
 *
 */
class ExploTower01 extends ExploTowerBase {
    
    /**武器*/
    private weapon:Explo01;
    
	public constructor() {
        super();
        this.minRadius = 100;
        this.maxRadius = 140;
        this.ratioY = this.minRadius / this.maxRadius;
        this.anchorOffsetX = 0.5 * this.width;
        this.anchorOffsetY = 1 * this.height;
        
        this.view = new egret.MovieClip();
        this.addChild(this.view);
        var data = RES.getRes("ExploTower01json");
        var texture = RES.getRes("ExploTower01png");
        var mcf: egret.MovieClipDataFactory = new egret.MovieClipDataFactory(data,texture);
        this.view.movieClipData = mcf.generateMovieClipData("ExploTower01");
        this.view.anchorOffsetX = 0.5 * this.view.width;
        this.view.x = this.view.width / 2;
        
        //初始化数据
        this.fireDelay = 2000;
	}
	
    /**实时刷新*/
    public onEnterFrame(advancedTime: number) {
        super.onEnterFrame(advancedTime);
        
        //进入范围敌人数组为空则直接返回
        if(this.atargets.length == 0) {
            this.timesum = this.fireDelay-299;
            return;
        }
        
        //取进入范围数组第一个
        this.target = this.atargets[0];
        
        //发射间隔
        this.timesum += advancedTime;
        if(this.timesum < this.fireDelay) {
            if(this.fireDelay - this.timesum < 300 && !this.isfire) {
                this.view.gotoAndPlay("shoot");//发射动作
                this.isfire = true;
            }
            return;
        }
        this.timesum = 0;
        this.isfire = false;
        
        //射击音效
        this.playFireVoice();
        
        //炮弹产生坐标点
        var p1: egret.Point;
        p1 = new egret.Point(this.sx,this.sy - 46);
        //利用对象池产生弓箭对象并进行碰撞检测
        this.weapon = <Explo01>ObjectPool.getInstance().createObject(Explo01);
        this.weapon.damage = 6;
        this.weapon.targets = this.atargets;
        this.weapon.init(p1,this.target,this.target.offy);
        this.contentLayer.addChild(this.weapon);
    }
    
    
}
