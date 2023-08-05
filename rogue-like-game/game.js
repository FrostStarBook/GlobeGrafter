var term = $('.term').terminal({
    rogue: function() {
        Game.init();
        this.disable().hide();
    }
}, {
    greetings: 'type [[b;#fff;]rogue] to start the game',
    completion: ['rogue'],
    exit: false
});

var Game = {
    display: null,
    map: [],
    player: null,
    maxGold: 150,
    maxHealth: 100,
    level: 1,
    init: function() {
        var container = $('.game');
        this.display = new ROT.Display();
        var size = this.display.computeSize(container.width(), container.height());
        this.width = size[0];
        this.height = size[1];
        this.display.setOptions({
            width: this.width,
            height: this.height
        });
        
        this._generateLevel();
    
        $(this.display.getContainer())
            .appendTo('.game');
    },
    destroy: function() {
        $('.game').empty();
        this.map = [];
        this.display = this.player = null;
        this.scheduler.clear();
        this.engine.lock();
        this.engine = null;
    }
};
// ---------------------------------------------------------------
