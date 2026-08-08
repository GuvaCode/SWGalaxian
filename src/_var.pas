unit _var;

interface

uses
  raylib, Classes;

type
  TGameState = (
    gsMenu,
    gsIntro_ALTA,
    gsIntro_pause,
    gsIntro_logo,
    gsIntro_text,
    gsIntro_scroll,
    gsGame
  );

  TInput = record
    Up, Down, Left, Right, B1, B2, Esc, Ent, Pause: boolean;
  end;

  TPlayer = record
    x, y: single;
    Lives: integer;
    Stage: integer;
    RPM: integer;
    RPM_current: integer;
    counting: longword;
    score: longword;
    hiscore: longword;
    speed: single;
    turret: boolean;   // Left or right laser cannon
    active: boolean;
    delay: integer;
    multishot: integer;
  end;

  TEnemy = record
    x, y, angle: single;
    turnrate: single;
    speed: single;
    score: integer;
    bif: byte;
    frame: single;
    order: byte;
    placex, placey: single;
    rallyx, rallyy: single;
    delay: integer;
    rallyID: integer;
    currentrally: integer;
    turn: smallint;
    tmp: single;
    hp: integer;
    ready: boolean;
    // color: byte;
  end;

  TShot = record
    x, y, dx, dy: single;
    angle: single;
    enemy: boolean;
    tp: byte;
    count: integer;
  end;

  TExpl = record
    x, y, angle, size: single;
    frame: integer;
    tp: byte;
  end;

  TRally = record
    x, y: single;
  end;

  TDelayAction = record
    delay: integer;
    ID: integer;
  end;

  TScore = record
    x, y: single;
    frame: integer;
    value: string;
  end;



const
  // --- Sounds ---
  Max_Sounds = 10;

  s_tiefly0 = 0;
  s_tiefly1 = 1;
  s_damage = 2;
  s_bomb = 3;
  s_zap = 4;
  s_shot1 = 5;
  s_shot2 = 6;
  s_Expl = 7;
  s_tie_shot2 = 8;
  s_blip = 9;
  s_r2d2 = 10;

  pi180 = 0.01745329251;
  ClickWait = 300;
  Shot_Speed = 6;
  hit_margin = 18;
  bonus = 70000;

  // tracks: array [0..3] of integer = (94, 249, 169, 248);

var
  swtext, swlogo, xwing, exh1, shot1, lives, rpm, multishot, bomb, enter, esc: TTexture;
  tief, tiei, tieb: TTexture;
  spark, blast, expl: TTexture;

  s: array[0..Max_Sounds] of TSound;

  logo_y: double;


  GameState: TGameState;
  introfade, dbl: double;

  tsl: TStringList;

  starsky: array[0..2, 0..50] of single;

  Input: TInput;
  delay: Double;

  Player: TPlayer;
  new_level: boolean;

  leftright, delta: single;
  attack: integer;
  pause: boolean;
  bonus_marker: longword;

  F: file of longword;

  a_shots_ally: array of TShot;
  a_shots_enemy: array of TShot;
  a_explosions: array of TExpl;
  a_enemy: array of TEnemy;
  a_rally: array of array of TRally;
  a_score: array of TScore;
  a_DelayAction: array of TDelayAction;
  a_bonus: array of TScore;

  MenuMusic: TMusic;
  IntroMusic:TMusic;

  camera: TCamera3D;
  fnt1, fnt2: TFont;


  CurrentMusic: TMusic;  // Текущая играющая музыка
  MusicInitialized: Boolean = false;

procedure Init_player(New: boolean = false);
procedure PlayGameSound(id: integer);

implementation

//----------------------------------------------------------------------------------------------------------------------------------------------------
procedure Init_player(New: boolean = false);
begin
  Player.x := 400;
  Player.speed := 2;
  Player.RPM := 50;
  Player.RPM_current := 0;
  Player.turret := false;
  Player.multishot := 1;

  if New then
  begin
    bonus_marker := bonus;
    Player.Lives := 3;
    Player.score := 0;
    Player.Stage := 0;
    Player.active := true;
    Player.y := 550;
    delay := 0;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
procedure PlayGameSound(id: integer);
begin
  if (id < Low(s)) or (id > High(s)) then
    Exit;

  if not IsAudioDeviceReady() then
    Exit;


   if not IsSoundValid(s[id]) then Exit;

  PlaySound(s[id]);
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
end.
