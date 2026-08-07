unit _update;

interface

uses
  _var, _draw, raylib, math, SysUtils;

var
  tmr: integer;

procedure update_menu;
procedure update_intro_ALTA;
procedure update_intro_pause;
procedure update_intro_logo;
procedure update_Intro_text;
procedure update_Intro_scroll;
procedure update_game;
procedure SwitchMusic(var NewMusic: TMusic);

implementation


  //----------------------------------------------------------------------------------------------------------------------------------------------------
  procedure SwitchMusic(var NewMusic: TMusic);
  begin
    // Если музыка уже играет, останавливаем её
    if MusicInitialized then
      StopMusicStream(CurrentMusic);

    // Запускаем новую музыку
    if NewMusic.ctxData <> nil then  // Проверяем, что музыка загружена
    begin
      PlayMusicStream(NewMusic);
      CurrentMusic := NewMusic;
      MusicInitialized := true;
    end;
  end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
procedure scroll_starsky(speed: single; layered: boolean = false);
var
  a: integer;
begin
  for a := 0 to high(starsky[0]) do
  begin
    if odd(a) then
      starsky[1, a] := starsky[1, a] + speed * 0.9
    else
      starsky[1, a] := starsky[1, a] + speed;

    if starsky[1, a] > 600 then
    begin
      starsky[0, a] := random(800);
      starsky[1, a] := 0;
      starsky[2, a] := (random(200) + 50) / 255;
    end;

    if starsky[1, a] < 0 then
    begin
      starsky[0, a] := random(800);
      starsky[1, a] := 600;
      starsky[2, a] := (random(200) + 50) / 255;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
procedure update_menu;
begin
  scroll_starsky(2, true);

  if input.Ent then
  begin
    GameState := gsIntro_ALTA;
    new_level := true;
    delay := trunc(GetTime() * 1000);
    SwitchMusic(IntroMusic);  // Переключаемся на интро музыку
    introfade := 0;
    tmr := 0;
  end;

  if input.esc then
    CloseWindow();
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
procedure make_shot(x, y: single; angle: single; shift: single; enemy: boolean; tp: byte = 0);
var
  a: integer;
  sht: TShot;
begin
  sht.dx := (Shot_Speed - tp * 2) * sin(angle * pi180);
  sht.dy := (Shot_Speed - tp * 2) * cos(angle * pi180);
  sht.x := x + shift * sht.dx;
  sht.y := y - shift * sht.dy;
  sht.enemy := enemy;
  sht.angle := angle;
  sht.tp := tp;
  sht.count := 0;

  if enemy then
  begin
    a := high(a_shots_enemy) + 1;
    SetLength(a_shots_enemy, a + 1);
    a_shots_enemy[a] := sht;
  end
  else
  begin
    a := high(a_shots_ally) + 1;
    SetLength(a_shots_ally, a + 1);
    a_shots_ally[a] := sht;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
function get_angle(x1, y1, x2, y2: single): single;
var
  xx, yy, res: single;
begin
  xx := x2 - x1;
  yy := y2 - y1;

  Result := 180;
  if (xx = 0) and (yy > 0) then
    Exit;

  Result := 0;
  if (xx = 0) and (yy < 0) then
    Exit;

  res := abs(arctan(yy / xx) / pi180);

  if (xx > 0) and (yy > 0) then
    res := 90 + res;

  if (xx < 0) and (yy > 0) then
    res := -1 * (90 + res);

  if (xx < 0) and (yy < 0) then
    res := -1 * (90 - res);

  if (xx > 0) and (yy < 0) then
    res := 90 - res;

  Result := res;
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
procedure make_explosion(x, y, angle, size: single; tp: byte = 1);
var
  a: integer;
begin
  a := high(a_explosions) + 1;
  SetLength(a_explosions, a + 1);

  a_explosions[a].x := x;
  a_explosions[a].y := y;
  a_explosions[a].angle := angle;
  a_explosions[a].size := size;
  a_explosions[a].frame := 0;
  a_explosions[a].tp := tp * 36;
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
procedure add_score(x, y: single; value: string);
var
  a: integer;
begin
  a := high(a_score) + 1;
  SetLength(a_score, a + 1);

  a_score[a].x := x - 32;
  a_score[a].y := y - 16;
  a_score[a].value := value;
  a_score[a].frame := 255;
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
procedure add_DA(Id, delay: integer);
var
  a: integer;
begin
  a := high(a_delayaction) + 1;
  SetLength(a_delayaction, a + 1);

  a_delayaction[a].ID := Id;
  a_delayaction[a].delay := delay;
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
procedure load_level(Lvl: integer);
var
  a, b, c, d, delay: integer;
  s1, s2: string;
  s3: char;
  filename: string;
  f: TextFile;
  line: string;
begin
  LeftRight := -1;
  delta := 0;

  // Формируем имя файла шаблона
  filename := 'data/template' + inttostr((Lvl) mod 5);

  // Очищаем TStringList перед загрузкой
  tsl.Clear;

  // Загружаем файл шаблона
  if FileExists(filename) then
  begin
    AssignFile(f, filename);
    Reset(f);

    while not EOF(f) do
    begin
      ReadLn(f, line);
      if Trim(line) <> '' then // Пропускаем пустые строки
        tsl.Add(line);
    end;

    CloseFile(f);
  end
  else
  begin
    // Если файл не найден, создаем шаблон по умолчанию
    tsl.Add('0001:0fhh2fih4fjh3fkh1flh 0da1dk5jk2em4im3gn');
    tsl.Add('0200:0fhi2fii4fji3fki1fli 0da1dk5jk2em4im3gn');
    tsl.Add('0400:8ihf6iif4ijf2ikf0ilf9fhg7fig5fjg3fkg1flg 7ff6dg3jl1rl5dk4fm2nm0xm');
  end;

  SetLength(a_rally, 0);
  SetLength(a_rally, tsl.Count);

  SetLength(a_enemy, 0);
  SetLength(a_score, 0);
  SetLength(a_delayaction, 0);
  SetLength(a_bonus, 0);

  attack := -1;

  for a := 0 to tsl.Count - 1 do
  begin
    // Проверяем, что строка не пустая и имеет достаточную длину
    if Length(tsl[a]) < 5 then
      Continue;

    delay := strtoint(copy(tsl[a], 1, 4));
    c := pos(' ', tsl[a]);

    if c = 0 then
      Continue; // Если нет пробела, пропускаем строку

    s1 := copy(tsl[a], 6, c - 6);
    s2 := copy(tsl[a], c + 1, length(tsl[a]));

    // Проверяем, что строки не пустые
    if (Length(s1) < 4) or (Length(s2) < 3) then
      Continue;

    SetLength(a_rally[a], (length(s2) div 3));

    for b := 1 to length(s2) div 3 do
    begin
      c := strtoint(s2[b * 3 - 2]);

      s3 := s2[b * 3 - 1];
      d := (ord(s3) - 99) * 40 + 20;
      a_rally[a][c].x := d;

      s3 := s2[b * 3];
      d := (ord(s3) - 99) * 40 + 20;
      a_rally[a][c].y := d;
    end;

    d := high(a_enemy) + 1;
    SetLength(a_enemy, d + (length(s1) div 4));

    for b := 1 to length(s1) div 4 do
    begin
      c := strtoint(s1[b * 4 - 3]) + d;

      case (s1[b * 4 - 2]) of
        'f': a_enemy[c].bif := 0;
        'i': a_enemy[c].bif := 1;
        'b': a_enemy[c].bif := 2;
      else
        a_enemy[c].bif := 0; // Значение по умолчанию
      end;

      a_enemy[c].score := (a_enemy[c].bif + 1) * 1000;
      a_enemy[c].delay := delay + (c - d) * 20 + 100;
      a_enemy[c].rallyID := a;
      a_enemy[c].x := a_rally[a][0].x;
      a_enemy[c].y := a_rally[a][0].y;
      a_enemy[c].rallyx := a_rally[a][1].x;
      a_enemy[c].rallyy := a_rally[a][1].y;
      a_enemy[c].currentrally := 1;
      a_enemy[c].angle := 180;
      a_enemy[c].turnrate := 4;
      a_enemy[c].turn := 0;
      a_enemy[c].hp := 2;
      a_enemy[c].frame := 0;
      a_enemy[c].speed := 4;
      a_enemy[c].order := 1;
      a_enemy[c].placex := (ord(s1[b * 4 - 1]) - 99) * 40 + 20;
      a_enemy[c].placey := (ord(s1[b * 4]) - 99) * 40 + 20;
      a_enemy[c].ready := false;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
procedure update_intro_ALTA;
begin
  if not MusicInitialized then
     SwitchMusic(IntroMusic);  // Убеждаемся, что интро музыка играет


  tmr := tmr + 1;

  if tmr < 85 then
    introfade := introfade + 3;

  if (tmr >= 85) and (tmr < 265) then
    introfade := 255;

  if (tmr >= 265) and (tmr < 350) then
    introfade := introfade - 3;

  if (tmr >= 350) then
  begin
    introfade := 0;
    tmr := 0;
    GameState := gsIntro_pause;
    dbl := 1;
    delay := trunc(GetTime() * 1000);
    // snd.PlayFile('intro.mid', false);


  end;

  if ((input.ent) or (input.B1)) and (trunc(GetTime() * 1000) - delay > ClickWait) then
  begin
    StopMusicStream(MenuMusic);
    StopMusicStream(IntroMusic);
    GameState := gsIntro_scroll;
    delay := trunc(GetTime() * 1000);
    dbl := 3;
    introfade := 0;


  end;
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
procedure update_intro_pause;
begin
  tmr := tmr + 1;

  if tmr >= 120 then
  begin
    introfade := 1024;
    GameState := gsIntro_logo;
    tmr := 700;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
procedure update_intro_logo;
begin
  introfade := introfade - introfade / 150;

  if (introfade < 3) then
  begin
    GameState := gsIntro_text;
    introfade := -790;
    input.Esc := false;
    input.B1 := false;
    delay := trunc(GetTime() * 1000);
  end;

  if ((input.ent) or (input.B1)) and (trunc(GetTime() * 1000) - delay > ClickWait) then
  begin

    StopMusicStream(MenuMusic);
    StopMusicStream(IntroMusic);


    GameState := gsIntro_scroll;

    delay := trunc(GetTime() * 1000);
    dbl := 3;
    introfade := 0;

  end;
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
procedure update_Intro_text;
begin
  introfade := introfade + 0.35;

  if (introfade > 440) then
  begin
    dbl := dbl - 0.004;
  end;

  if (dbl < 0.02) then
  begin
    GameState := gsIntro_scroll;
    delay := trunc(GetTime() * 1000);
    dbl := 3;
    introfade := 0;
  end;

  if ((input.ent) or (input.B1)) and (trunc(GetTime() * 1000) - delay > ClickWait) then
  begin
        StopMusicStream(MenuMusic);
    StopMusicStream(IntroMusic);
    GameState := gsIntro_scroll;

    delay := trunc(GetTime() * 1000);
    dbl := 3;
    introfade := 0;

  end;
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
procedure update_Intro_scroll;
begin
  scroll_starsky(dbl);
  introfade := introfade + dbl;

  if (introfade >= 800) then
  begin
    Init_player(true);
    GameState := gsGame;

    // TODO - Если есть игровая музыка, переключаемся на неё:
        StopMusicStream(MenuMusic);
    StopMusicStream(IntroMusic);
    SetLength(a_explosions, 0);
    SetLength(a_shots_ally, 0);
    SetLength(a_shots_enemy, 0);
    SetLength(a_rally, 0);
    SetLength(a_enemy, 0);
    SetLength(a_score, 0);
    SetLength(a_delayaction, 0);
    SetLength(a_bonus, 0);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
procedure update_game;
var
  a, b, c, de, trn, orderA, orderB: integer;
  ang, dx, dy: single;
  a_enemy_orderC: array of integer;
  f: TextFile;
begin
  if new_level then
  begin
    new_level := false;
    load_level(player.Stage);
  end;

  if input.pause and (trunc(GetTime() * 1000) - delay > ClickWait) then
  begin
    delay := trunc(GetTime() * 1000);
    pause := not pause;
  end;

  if input.esc then
  begin
    if player.hiscore < player.score then
    begin
      player.hiscore := player.score;
      AssignFile(f, 'cr.hsc');
      Rewrite(f);
      Write(f, player.score);
      CloseFile(f);
    end;

    GameState := gsMenu;
    SwitchMusic(MenuMusic);  // Возвращаемся к музыке меню

  end;

  if pause then
    Exit;

  scroll_starsky(+2, true);

  if player.score > bonus_marker then
  begin
    inc(bonus_marker, bonus);

    a := high(a_bonus) + 1;
    SetLength(a_bonus, a + 1);

    a_bonus[a].x := random(700) + 50;
    a_bonus[a].y := -64;
    a_bonus[a].frame := 0;
    a_bonus[a].value := inttostr(random(3));
  end;

  if player.active then
  begin
    if input.Right then
      player.x := player.x + player.speed;

    if player.x > 768 then
      player.x := 768;

    if input.Left then
      player.x := player.x - player.speed;

    if player.x < 32 then
      player.x := 32;

    if (input.B1) and (player.RPM_current = 0) then
    begin
      player.RPM_current := player.RPM;

      if player.turret then
      begin
        a := 16;

        if player.multishot > 1 then
          make_shot(player.x + a, player.y, +4, 2, false);

        if player.multishot > 2 then
          make_shot(player.x + a, player.y, -4, 2, false);
      end
      else
      begin
        a := -16;

        if player.multishot > 1 then
          make_shot(player.x + a, player.y, -4, 2, false);

        if player.multishot > 2 then
          make_shot(player.x + a, player.y, +4, 2, false);
      end;

      player.turret := not player.turret;

      make_shot(player.x + a, player.y, 0, 2, false);

      PlayGameSound(s_shot1 + random(2));
    end;
  end;

  if player.RPM_current > 0 then
    player.RPM_current := player.RPM_current - 1;

  orderA := 0;
  orderB := 0;
  b := 0;

  SetLength(a_enemy_orderC, high(a_enemy) + 1);

  if high(a_enemy) >= 0 then
    for a := 0 to high(a_enemy) do
    begin
      if not a_enemy[a].ready then
        inc(orderA);

      if a_enemy[a].order = 4 then
      begin
        a_enemy_orderC[b] := a;
        inc(b);
      end;
    end;

  SetLength(a_enemy_orderC, b);

  if orderA > 0 then
    attack := -1;

  if player.active then
    if orderA = 0 then
      if attack <= 0 then
        if high(a_enemy_orderC) >= 0 then
          attack := ((high(a_enemy) + 1) * 3 + random(50) + 50);

  if attack > 0 then
    dec(attack);

  if attack = 0 then
  begin
    attack := -1;

    if high(a_enemy_orderC) >= 0 then
    begin
      if (random(8) = 0) and (high(a_enemy_orderC) > 2) then
        b := 2
      else
        b := 0;

      c := random(high(a_enemy_orderC) - b + 1);

      if high(a_enemy_orderC) = 0 then
        c := 0;

      PlayGameSound(s_tiefly0 + random(2));

      for a := c to c + b do
      begin
        a_enemy[a_enemy_orderC[a]].order := 5;

        if a_enemy[a_enemy_orderC[a]].x > 400 then
          a_enemy[a_enemy_orderC[a]].turn := -2
        else
          a_enemy[a_enemy_orderC[a]].turn := 2;

        a_enemy[a_enemy_orderC[a]].turnrate := 3;
        a_enemy[a_enemy_orderC[a]].speed := 3;

        if a_enemy[a_enemy_orderC[a]].turn < 0 then
          a_enemy[a_enemy_orderC[a]].frame := +17
        else
          a_enemy[a_enemy_orderC[a]].frame := -17;
      end;
    end;
  end;

  delta := delta + leftright;
  de := 0;

  if high(a_enemy) >= 0 then
    for a := 0 to high(a_enemy) do
    begin
      if a_enemy[a].delay > 0 then
        dec(a_enemy[a].delay)
      else
      begin
        if a_enemy[a].placex + delta < 20 then
          leftright := 1;

        if a_enemy[a].placex + delta > 780 then
          leftright := -1;

        if a_enemy[a].order = 2 then
          a_enemy[a].rallyx := a_enemy[a].placex + delta;

        if sqrt(sqr(abs(player.x) - abs(a_enemy[a].x)) +
                  sqr(abs(player.y) - abs(a_enemy[a].y))) < 32 then
        begin
          a_enemy[a].hp := 0;
          dec(player.Lives);

          make_explosion(player.x, 556, 0, 96, 1);
          PlayGameSound(s_damage);

          player.y := 1000;
          Init_player;
          player.active := false;
        end;

        if random(1000) = 0 then
          if a_enemy[a].frame = 0 then
            if random(2) = 0 then
              a_enemy[a].frame := 17
            else
              a_enemy[a].frame := -17;

        if a_enemy[a].frame > 0 then
          a_enemy[a].frame := a_enemy[a].frame - 0.5;

        if a_enemy[a].frame < 0 then
          a_enemy[a].frame := a_enemy[a].frame + 0.5;

        ang := get_angle(a_enemy[a].x, a_enemy[a].y, a_enemy[a].rallyx, a_enemy[a].rallyy);

        if a_enemy[a].order in [1..2] then
        begin
          if abs(ang - a_enemy[a].angle) <= 1 then
            a_enemy[a].angle := ang;

          ang := ang - a_enemy[a].angle;

          if ang > 180 then
            ang := ang - 360;

          if ang < -180 then
            ang := ang + 360;

          a_enemy[a].turn := 0;

          if ang > 0 then
            if ang < a_enemy[a].turnrate then
              a_enemy[a].angle := a_enemy[a].angle + ang
            else
            begin
              a_enemy[a].angle := a_enemy[a].angle + a_enemy[a].turnrate;
              a_enemy[a].turn := +1;

              if a_enemy[a].frame = 0 then
                a_enemy[a].frame := -17;
            end;

          if ang < 0 then
            if abs(ang) < a_enemy[a].turnrate then
              a_enemy[a].angle := a_enemy[a].angle + ang
            else
            begin
              a_enemy[a].angle := a_enemy[a].angle - a_enemy[a].turnrate;
              a_enemy[a].turn := -1;

              if a_enemy[a].frame = 0 then
                a_enemy[a].frame := +17;
            end;

          dx := a_enemy[a].speed * sin(a_enemy[a].angle * pi180);
          dy := a_enemy[a].speed * cos(a_enemy[a].angle * pi180);

          a_enemy[a].x := a_enemy[a].x + dx;
          a_enemy[a].y := a_enemy[a].y - dy;

          if a_enemy[a].angle > 180 then
            a_enemy[a].angle := a_enemy[a].angle - 360;

          if (a_enemy[a].ready) and (a_enemy[a].order = 1) then
            a_enemy[a].rallyx := a_enemy[a].placex + delta;

          if (abs((abs(a_enemy[a].x) - abs(a_enemy[a].rallyx))) < 6) and
             (abs((abs(a_enemy[a].y) - abs(a_enemy[a].rallyy))) < 6) then
          begin
            if high(a_rally[a_enemy[a].rallyID]) > a_enemy[a].currentrally then
            begin
              inc(a_enemy[a].currentrally);
              a_enemy[a].rallyx := a_rally[a_enemy[a].rallyID][a_enemy[a].currentrally].x;
              a_enemy[a].rallyy := a_rally[a_enemy[a].rallyID][a_enemy[a].currentrally].y;
            end
            else if a_enemy[a].order = 1 then
            begin
              if a_enemy[a].ready then
                if (random(6) = 0) and (player.active) then
                begin
                  a_enemy[a].order := 5;

                  if a_enemy[a].x > 400 then
                    a_enemy[a].turn := -2
                  else
                    a_enemy[a].turn := 2;

                  a_enemy[a].turnrate := 3;
                  a_enemy[a].speed := 3;

                  if a_enemy[a].turn < 0 then
                    a_enemy[a].frame := +17
                  else
                    a_enemy[a].frame := -17;
                end;

              if a_enemy[a].order <> 5 then
              begin
                a_enemy[a].rallyx := a_enemy[a].placex + delta;
                a_enemy[a].rallyy := a_enemy[a].placey;
                a_enemy[a].turnrate := 8;
                a_enemy[a].speed := 2;
                a_enemy[a].order := 2;
              end;
            end
            else
            begin
              if (abs((abs(a_enemy[a].x) - abs(a_enemy[a].rallyx))) < 2.1) and
                 (abs((abs(a_enemy[a].y) - abs(a_enemy[a].rallyy))) < 2.1) then
              begin
                a_enemy[a].x := a_enemy[a].placex + delta;
                a_enemy[a].y := a_enemy[a].placey;
                a_enemy[a].turnrate := 4;
                a_enemy[a].order := 3;
              end;
            end;
          end;
        end;

        case a_enemy[a].order of
          3:
          begin
            a_enemy[a].turn := 0;

            if a_enemy[a].angle > 0 then
            begin
              a_enemy[a].turn := -4;

              if a_enemy[a].frame = 0 then
                a_enemy[a].frame := +17;
            end;

            if a_enemy[a].angle < 0 then
            begin
              a_enemy[a].turn := +4;

              if a_enemy[a].frame = 0 then
                a_enemy[a].frame := -17;
            end;

            a_enemy[a].angle := a_enemy[a].angle + a_enemy[a].turn;

            if abs(a_enemy[a].angle) <= 4 then
              a_enemy[a].angle := 0;

            a_enemy[a].x := a_enemy[a].placex + delta;

            if a_enemy[a].angle = 0 then
            begin
              a_enemy[a].order := 4;
              a_enemy[a].turn := 0;
              a_enemy[a].ready := true;
            end;
          end;

          4:
          begin
            a_enemy[a].x := a_enemy[a].placex + delta;
          end;

          5:
          begin
            a_enemy[a].angle := a_enemy[a].angle + a_enemy[a].turn;

            if a_enemy[a].angle > 180 then
              a_enemy[a].angle := a_enemy[a].angle - 360;

            if a_enemy[a].angle < -180 then
              a_enemy[a].angle := a_enemy[a].angle + 360;

            dx := a_enemy[a].speed * sin(a_enemy[a].angle * pi180);
            dy := a_enemy[a].speed * cos(a_enemy[a].angle * pi180);

            a_enemy[a].x := a_enemy[a].x + dx;
            a_enemy[a].y := a_enemy[a].y - dy;

            ang := get_angle(a_enemy[a].x, a_enemy[a].y, player.x, player.y);

            if abs((ang) - (a_enemy[a].angle)) <= 2 then
            begin
              a_enemy[a].rallyx := a_enemy[a].placex + delta;
              a_enemy[a].rallyy := 300;
              a_enemy[a].order := 1;
              a_enemy[a].turnrate := 2;

              case a_enemy[a].bif of
                0:
                begin
                  dx := 5 * sin((a_enemy[a].angle + 90) * pi180);
                  dy := 5 * cos((a_enemy[a].angle + 90) * pi180);
                  make_shot(a_enemy[a].x + dx, a_enemy[a].y - dy, a_enemy[a].angle, 1, true);

                  dx := 5 * sin((a_enemy[a].angle - 90) * pi180);
                  dy := 5 * cos((a_enemy[a].angle - 90) * pi180);
                  make_shot(a_enemy[a].x + dx, a_enemy[a].y - dy, a_enemy[a].angle, 1, true);

                  add_DA(s_tie_shot2, 8);
                end;

                1:
                begin
                  dx := 10 * sin((a_enemy[a].angle + 90) * pi180);
                  dy := 10 * cos((a_enemy[a].angle + 90) * pi180);
                  make_shot(a_enemy[a].x + dx, a_enemy[a].y - dy, a_enemy[a].angle + 1, 2, true);

                  dx := 10 * sin((a_enemy[a].angle - 90) * pi180);
                  dy := 10 * cos((a_enemy[a].angle - 90) * pi180);
                  make_shot(a_enemy[a].x + dx, a_enemy[a].y - dy, a_enemy[a].angle - 1, 2, true);

                  dx := 5 * sin((a_enemy[a].angle + 90) * pi180);
                  dy := 5 * cos((a_enemy[a].angle + 90) * pi180);
                  make_shot(a_enemy[a].x + dx, a_enemy[a].y - dy, a_enemy[a].angle, 1, true);

                  dx := 5 * sin((a_enemy[a].angle - 90) * pi180);
                  dy := 5 * cos((a_enemy[a].angle - 90) * pi180);
                  make_shot(a_enemy[a].x + dx, a_enemy[a].y - dy, a_enemy[a].angle, 1, true);

                  add_DA(s_tie_shot2, 8);
                end;

                2:
                begin
                  make_shot(a_enemy[a].x, a_enemy[a].y, a_enemy[a].angle, 1, true, 1);
                  PlayGameSound(s_bomb);
                end;
              end;
            end;
          end;

          200:
          begin
            if a_enemy[a].angle < 0 then
              a_enemy[a].angle := a_enemy[a].angle - a_enemy[a].turnrate;

            if a_enemy[a].angle > 0 then
              a_enemy[a].angle := a_enemy[a].angle + a_enemy[a].turnrate;

            if (a_enemy[a].angle > 180) or (a_enemy[a].angle < -180) then
              a_enemy[a].angle := 180;

            if abs(a_enemy[a].frame) < 1 then
              a_enemy[a].frame := 18 * a_enemy[a].turn;

            a_enemy[a].frame := a_enemy[a].frame - a_enemy[a].turn / 5;

            dx := a_enemy[a].speed * sin(a_enemy[a].angle * pi180);
            dy := a_enemy[a].speed * cos(a_enemy[a].angle * pi180);

            a_enemy[a].x := a_enemy[a].x + dx;
            a_enemy[a].y := a_enemy[a].y - dy;

            if a_enemy[a].angle > 180 then
              a_enemy[a].angle := a_enemy[a].angle - 360;

            if a_enemy[a].hp < 0 then
              inc(a_enemy[a].hp);

            if a_enemy[a].hp mod 2 = 0 then
              make_explosion(a_enemy[a].x + random(8) - 4, a_enemy[a].y + random(8) - 4, random(360), 32);

            if a_enemy[a].hp = 0 then
            begin
              make_explosion(a_enemy[a].x, a_enemy[a].y, random(360), 96);
              PlayGameSound(s_expl);
            end;
          end;
        end;
      end;

      if high(a_shots_ally) >= 0 then
        for b := 0 to high(a_shots_ally) do
        begin
          if (abs(abs(a_shots_ally[b].x) - abs(a_enemy[a].x)) < hit_margin) and
             (abs(abs(a_shots_ally[b].y) - abs(a_enemy[a].y)) < hit_margin) and
             (a_enemy[a].delay = 0) and (a_enemy[a].hp > 0) then
          begin
            a_shots_ally[b].y := -1000;

            add_score(a_enemy[a].x, a_enemy[a].y, inttostr(a_enemy[a].score));
            player.score := player.score + a_enemy[a].score;

            make_explosion(a_enemy[a].x, a_enemy[a].y, random(360), 64);
            PlayGameSound(s_expl);

            a_enemy[a].hp := 0;

            if (a_enemy[a].order in [1, 2, 5]) and (random(2) = 0) then
            begin
              PlayGameSound(s_zap);

              a_enemy[a].order := 200;
              a_enemy[a].hp := -(random(80) + 80);

              if random(2) = 0 then
                a_enemy[a].turn := -1
              else
                a_enemy[a].turn := 1;

              a_enemy[a].turnrate := 1;
            end
            else
            begin
              a_enemy[a].hp := 0;
            end;
          end;
        end;

      if a_enemy[a].hp <> 0 then
      begin
        a_enemy[de] := a_enemy[a];
        inc(de);
      end;
    end;

  SetLength(a_enemy, de);

  // Ally shots
  b := 0;

  if high(a_shots_ally) >= 0 then
  begin
    for a := 0 to high(a_shots_ally) do
      if (a_shots_ally[a].y > 0) and (a_shots_ally[a].y < 600) and
         (a_shots_ally[a].x > 0) and (a_shots_ally[a].x < 800) then
      begin
        a_shots_ally[a].x := a_shots_ally[a].x + a_shots_ally[a].dx;
        a_shots_ally[a].y := a_shots_ally[a].y - a_shots_ally[a].dy;

        a_shots_ally[b] := a_shots_ally[a];
        inc(b);
      end;

    SetLength(a_shots_ally, b);
  end;

  // Enemy shots
  b := 0;

  if high(a_shots_enemy) >= 0 then
  begin
    for a := 0 to high(a_shots_enemy) do
      if (a_shots_enemy[a].y > 0) and (a_shots_enemy[a].y < 600) and
         (a_shots_enemy[a].x > 0) and (a_shots_enemy[a].x < 800) then
      begin
        a_shots_enemy[a].x := a_shots_enemy[a].x + a_shots_enemy[a].dx;
        a_shots_enemy[a].y := a_shots_enemy[a].y - a_shots_enemy[a].dy;

        if (abs(abs(player.x) - abs(a_shots_enemy[a].x)) <= hit_margin) and
           (abs(abs(player.y) - abs(a_shots_enemy[a].y)) <= hit_margin) then
        begin
          dec(player.Lives);

          make_explosion(player.x, player.y, 0, 96, 1);
          PlayGameSound(s_damage);

          player.y := 1000;
          Init_player;
          player.active := false;
        end;

        if a_shots_enemy[a].tp = 1 then
        begin
          inc(a_shots_enemy[a].count);

          if (a_shots_enemy[a].count mod 20 = 1) and (a_shots_enemy[a].count > 3) then
            PlayGameSound(s_blip);

          if a_shots_enemy[a].y > 530 then
          begin
            make_explosion(a_shots_enemy[a].x, a_shots_enemy[a].y, 0, 196, 0);
            PlayGameSound(s_expl);

            if sqrt(sqr(abs(player.x) - abs(a_shots_enemy[a].x)) +
                      sqr(abs(player.y) - abs(a_shots_enemy[a].y))) < 100 then
            begin
              dec(player.Lives);

              make_explosion(player.x, 556, 0, 96, 1);
              PlayGameSound(s_damage);

              player.y := 1000;
              Init_player;
              player.active := false;
            end;

            a_shots_enemy[a].y := -1000;
          end;
        end;

        a_shots_enemy[b] := a_shots_enemy[a];
        inc(b);
      end;

    SetLength(a_shots_enemy, b);
  end;

  // Explosions
  b := 0;

  if high(a_explosions) >= 0 then
  begin
    for a := 0 to high(a_explosions) do
      if a_explosions[a].frame < 35 then
      begin
        a_explosions[b] := a_explosions[a];
        inc(a_explosions[b].frame);
        inc(b);
      end;

    SetLength(a_explosions, b);
  end;

  // Score
  b := 0;

  if high(a_score) >= 0 then
  begin
    for a := 0 to high(a_score) do
      if a_score[a].frame > 1 then
      begin
        a_score[a].frame := a_score[a].frame - 2;
        a_score[a].y := a_score[a].y - 1;

        a_score[b] := a_score[a];
        inc(b);
      end;

    SetLength(a_score, b);
  end;

  // Delayed action
  b := 0;

  if high(a_delayaction) >= 0 then
  begin
    for a := 0 to high(a_delayaction) do
    begin
      if a_delayaction[a].delay > 0 then
      begin
        dec(a_delayaction[a].delay);

        a_delayaction[b] := a_delayaction[a];
        inc(b);
      end
      else
      begin
        PlayGameSound(a_delayaction[a].ID);
      end;
    end;

    SetLength(a_delayaction, b);
  end;

  // Bonus
  b := 0;

  if high(a_bonus) >= 0 then
  begin
    for a := 0 to high(a_bonus) do
    begin
      if sqrt(sqr(abs(player.x) - abs(a_bonus[a].x)) +
                sqr(abs(player.y) - abs(a_bonus[a].y))) < 32 then
      begin
        case a_bonus[a].value[1] of
          '0':
          begin
            add_score(a_bonus[a].x + 10, a_bonus[a].y - 4, '+1  Life');
            inc(player.Lives);
          end;

          '1':
          begin
            add_score(a_bonus[a].x + 10, a_bonus[a].y - 4, 'Rapid fire');
            player.RPM := player.RPM - 10;

            if player.RPM < 20 then
              player.RPM := 20;
          end;

          '2':
          begin
            add_score(a_bonus[a].x + 10, a_bonus[a].y - 4, 'Multi shot');
            player.multishot := player.multishot + 1;

            if player.multishot > 3 then
              player.multishot := 3;
          end;
        end;

        a_bonus[a].y := 700;
        PlayGameSound(s_r2d2);
      end;

      if a_bonus[a].y < 700 then
      begin
        a_bonus[a].y := a_bonus[a].y + 2;
        a_bonus[b] := a_bonus[a];
        inc(b);
      end;
    end;

    SetLength(a_bonus, b);
  end;

  if player.counting < player.score then
    inc(player.counting, 50);

  if (high(a_enemy) < 0) and (high(a_explosions) < 0) and
     (high(a_score) < 0) and (high(a_shots_enemy) < 0) and
     (high(a_bonus) < 0) then
  begin
    inc(player.Stage);
    new_level := true;
  end;

  if not player.active then
  begin
    if player.delay > 0 then
      dec(player.delay);

    if (high(a_explosions) < 0) and (high(a_shots_enemy) < 0) and
       (player.delay = 0) and ((high(a_enemy_orderC) = high(a_enemy)) or (orderA <> 0)) then
    begin
      if (player.Lives > 0) then
      begin
        player.active := true;
        player.x := 400;
        player.y := 550;
      end
      else
      begin
        if player.hiscore < player.score then
        begin
          player.hiscore := player.score;
          AssignFile(f, 'cr.hsc');
          Rewrite(f);
          Write(f, player.score);
          CloseFile(f);
        end;

        GameState := gsMenu;
        SwitchMusic(MenuMusic);
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
end.
