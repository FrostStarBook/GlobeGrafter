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
Game.drawStats = function() {
    //clear previous text
    var spaces = new Array(this.width).fill(' ').join('');
    this.display.drawText(0, this.height - 1, spaces);
    
    this.display.drawText(0, this.height - 1,
                          "Gold: " + this.player.getGold() +
                          " Dungeon: " + this.level +
                          " Level: " + this.player.getLevel() +
                          " Exp: " + this.player.getExp() +
                          " Health: " + this.player.getHealth() +
                          " AC: " + this.player.getAC());
};
// ---------------------------------------------------------------
Game.drawTile = function(player, x, y, kill) {
    var enemy = Game.enemyPosition(x, y);
    if (enemy && (kill && (kill.getX() !== x && kill.getY() === y) ||
       !kill)) {
        enemy._draw();
    } else {
        var chr = player.getX() == x &&
            player.getY() === y ? '😁' : Game.map[y][x].chr;
        var color;
        if (['🚪', '/'].includes(chr)) {
            color = '#82290F';
        } else if (['💰', '😁'].includes(chr)) {
            color = "#ff0";
        } else {
            color = "#fff";
        }
        Game.display.draw(x, y, chr, color);
    }
};
// ---------------------------------------------------------------
Game._generateLevel = function(stairs) {
    console.log('--------------');
    var map = new ROT.Map.Digger(this.width, this.height - 1);
    var freeCells = [];
    this.map = [];
    var digCallback = function(x, y, value) {
        this.map[y] = this.map[y] || [];
        
        this.map[y][x] = {
            chr: value ? '#' : '.',
            value: null,
            visited: false
        };
        if (!value) {
            freeCells.push({x,y});
        }
    };
    map.create(digCallback.bind(this));
    var rooms = map.getRooms();
    for (var i=0; i<rooms.length; i++) {
        var room = rooms[i];
        room.getDoors(function(x, y) {
            var rand = Math.round(ROT.RNG.getUniform());
            this.map[y][x] = {chr: rand ? '/' : '🚪'};
            for (var i = 0; i<freeCells.length; ++i) {
                var point = freeCells[i];
                if (point.x === x && point.y === y) {
                    freeCells.splice(i, 1);
                    break;
                }
            }
        }.bind(this));
    }
    this._generateGold(freeCells);
    this._generatePotions(freeCells);
    this._generateStairs(freeCells, stairs === '🌟' ? '⭐' : '🌟');
    this.enemies = this._createEnemies(freeCells, rand(5, 10));
    
    this.display.clear();
    if (stairs) {
        var p = this._generateStairs(freeCells, stairs);
        console.log(freeCells.length);
        this.player._x = p.x;
        this.player._y = p.y;
    } else {
        var lightPasses = function(x, y) {
            if (this.isFreeCell(null, x, y)) {
                this.map[y][x].visited = true;
                return true;
            }
            return false;
        }.bind(this);

        this.fov = new ROT.FOV.PreciseShadowcasting(lightPasses);
        this.player = this._createPlayer(freeCells);
    }
    this.drawStats();
    this._runScheduler();
    return freeCells;
};
// ---------------------------------------------------------------
Game._runScheduler = function() {
    if (this.engine) {
        this.engine.lock();
    }
    this.scheduler = new ROT.Scheduler.Simple();
    this.scheduler.add(this.player, true);
    this.enemies.forEach(function(enemy) {
        this.scheduler.add(enemy, true);
    }.bind(this));
    this.engine = new ROT.Engine(this.scheduler);
    this.engine.start();
}
// ---------------------------------------------------------------
function Weapon(min, max) {
    this._min = min;
    this._max = max;
}
Weapon.prototype.damage = function() {
    return rand(this._min, this._max);
}
// ---------------------------------------------------------------
Game.debug_map = function() {
    var str = this.map.map(function(row, y) {
        return row.map(function(cell, x) {
            if (x == Game.player.getX() && y == Game.player.getY()) {
                return '😁';
            }
            return cell.chr;
        }).join('');
    }).join('\n')
    console.log(str);
};

// ---------------------------------------------------------------
function rand(min, max) {
    return ROT.RNG.getUniformInt(min, max);
}
function randIndex(array) {
    return rand(0, array.length - 1);
}
function randomCell(cells) {
    if (!cells.length) {
        Game.debug_map();
        throw Error('Internal Error, no free cells');
    }
    var index = randIndex(cells);
    var cell = cells.splice(index, 1)[0];
    return cell;
}
// ---------------------------------------------------------------
Game._generateGold = function(freeCells) {
    Game._generateGoodies(freeCells, 5, 10, function() {
        var gold = rand(5, this.maxGold);
        return {chr: "💰", value: gold};
    });
};
// ---------------------------------------------------------------
Game._generateGoodies = function(freeCells, min, max, fn) {
   var max = rand(min, max);
    for (var i = 0; i < max; i++) {
        var cell = randomCell(freeCells);
        this.map[cell.y][cell.x] = fn.call(this);
    }
}
// ---------------------------------------------------------------
Game._generatePotions = function(freeCells) {
    Game._generateGoodies(freeCells, 2, 5, function() {
        var healing = rand(10, 20);
        return {chr: "🍗", value: healing};
    });
}
// ---------------------------------------------------------------
Game._generateStairs = function(freeCells, chr) {
    if (chr === '⭐' && this.level > 1 || chr === '🌟') {
        var cell = randomCell(freeCells);
        this.map[cell.y][cell.x] = {chr: chr};
        return cell;
    }
};
// ---------------------------------------------------------------
Game.isFreeCell = function(being, x, y) {
    if (being) {
        if (being.getX() === x && being.getY() === y) {
            return true;
        }
        if (Game.enemyPosition(x, y)) {
            return false;
        }
        if (Game.player.getX() === x && Game.player.getY() === y) {
            return false;
        }
    }
    var row = this.map[y];
    return row && row[x] && ['💰', '.', '🌟', '⭐', '/', '🍗'].includes(row[x].chr);
};

// ---------------------------------------------------------------
Game.areNeighbor = function(p1, p2) {
    return p1.getX() + 1 == p2.getX() && p1.getY() === p2.getY() ||
        p1.getX() - 1 == p2.getX() && p1.getY() === p2.getY() ||
        p1.getX() == p2.getX() && p1.getY() - 1 === p2.getY() ||
        p1.getX() == p2.getX() && p1.getY() + 1 === p2.getY() ||
        p1.getX() + 1 == p2.getX() && p1.getY() + 1 === p2.getY() ||
        p1.getX() + 1 == p2.getX() && p1.getY() - 1 === p2.getY() ||
        p1.getX() - 1 == p2.getX() && p1.getY() - 1 === p2.getY() ||
        p1.getX() - 1 == p2.getX() && p1.getY() + 1 === p2.getY();
};
// ---------------------------------------------------------------
Game.enemyPosition = function(x, y) {
    var enemies = this.enemies.filter(function(enemy) {
        return enemy.getX() === x && enemy.getY() === y;
    });
    if (enemies.length) {
        if (enemies.length > 1) {
            console.log('error', enemies.length);
        }
        return enemies[0];
    }
    return null;
}
// ---------------------------------------------------------------
Game._createPlayer = function(freeCells) {
    var cell = randomCell(freeCells);
    return new Player(cell.x, cell.y, new Weapon(2, 10));
};
function enemyWeapon() {
    var min = rand(1, 3);
    var max = rand(min, min + 2);
    return new Weapon(min, max);
}
