program GalaxianWar;

uses
  SysUtils,
  Classes,
  raylib,
  _var,
  _load,
  _draw,
  _render,
  _update;

const
  SCREEN_WIDTH  = 800;
  SCREEN_HEIGHT = 600;
  LOGIC_STEP    = 1.0 / 60.0;  // 60 тиков в секунду

var
  Key_Ent_Pressed:   Boolean = false;
  Key_ESC_Pressed:   Boolean = false;
  Key_PAUSE_Pressed: Boolean = false;

  IntroLogoPositionX, IntroLogoPositionY: Integer;
  IntroFramesCounter, IntroLettersCount: Integer;
  IntroTopSideRecWidth, IntroLeftSideRecHeight: Integer;
  IntroBottomSideRecWidth, IntroRightSideRecHeight: Integer;
  IntroState: Integer;
  IntroAlpha: Single;
  IntroTimer: Single;

//----------------------------------------------------------------------------------------------------------------------------------------------------
// Процедура отрисовки и логики заставки
procedure PlayIntro();
var
  FadeFactor: Single;
  bgColor: TColor;
  DeltaTime: Single;
  AnimationSpeed: Single;
begin
  // Инициализация переменных интро
  IntroLogoPositionX := GetScreenWidth div 2 - 128;
  IntroLogoPositionY := GetScreenHeight div 2 - 128;
  IntroFramesCounter := 0;
  IntroLettersCount := 0;
  IntroTopSideRecWidth := 16;
  IntroLeftSideRecHeight := 16;
  IntroBottomSideRecWidth := 16;
  IntroRightSideRecHeight := 16;
  IntroState := 0;
  IntroAlpha := 1.0;
  IntroTimer := 0.0; // Таймер для паузы в состоянии 0

  FadeFactor := 1.0; // 1.0 = Белый (RAYWHITE), 0.0 = Черный (BLACK)

  // Цикл интро
  while not WindowShouldClose() do
  begin
    // Получаем время между кадрами
    DeltaTime := GetFrameTime();

    // Базовая скорость анимации (при 60 FPS будет давать такие же значения как раньше)
    AnimationSpeed := 1.0;

    // --- UPDATE INTRO ---
    if IntroState = 0 then
    begin
      // Используем таймер вместо счетчика кадров
      IntroTimer := IntroTimer + DeltaTime;
      if IntroTimer >= 2.0 then // 2 секунды (было 120 кадров при 60 FPS)
      begin
        IntroState := 1;
        IntroTimer := 0.0;
      end;
    end
    else if IntroState = 1 then
    begin
      // Рост со скоростью ~240 пикселей в секунду (было 4 пикселя за кадр при 60 FPS)
      IntroTopSideRecWidth := IntroTopSideRecWidth + Round(240.0 * DeltaTime);
      IntroLeftSideRecHeight := IntroLeftSideRecHeight + Round(240.0 * DeltaTime);

      if IntroTopSideRecWidth >= 256 then
      begin
        IntroTopSideRecWidth := 256;
        IntroLeftSideRecHeight := 256;
        IntroState := 2;
      end;
    end
    else if IntroState = 2 then
    begin
      // Рост со скоростью ~240 пикселей в секунду
      IntroBottomSideRecWidth := IntroBottomSideRecWidth + Round(240.0 * DeltaTime);
      IntroRightSideRecHeight := IntroRightSideRecHeight + Round(240.0 * DeltaTime);

      if IntroBottomSideRecWidth >= 256 then
      begin
        IntroBottomSideRecWidth := 256;
        IntroRightSideRecHeight := 256;
        IntroState := 3;
        IntroTimer := 0.0;
      end;
    end
    else if IntroState = 3 then
    begin
      // Появление букв с интервалом 0.2 секунды (было 12 кадров при 60 FPS)
      IntroTimer := IntroTimer + DeltaTime;
      if IntroTimer >= 0.2 then
      begin
        if IntroLettersCount < 10 then
          Inc(IntroLettersCount);
        IntroTimer := 0.0;
      end;

      // Когда все буквы появились, начинаем затухание
      if IntroLettersCount >= 10 then
      begin
        // Затухание со скоростью 0.02 за кадр при 60 FPS = 1.2 в секунду
        IntroAlpha := IntroAlpha - (1.2 * DeltaTime);
        if IntroAlpha <= 0.0 then
        begin
          IntroAlpha := 0.0;
          IntroState := 4; // Логотип исчез, переходим к затемнению фона
        end;
      end;
    end
    else if IntroState = 4 then
    begin
      // Плавный переход фона от белого к черному
      // Скорость затемнения: 0.02 за кадр при 60 FPS = 1.2 в секунду
      FadeFactor := FadeFactor - (1.2 * DeltaTime);

      if FadeFactor <= 0.0 then
      begin
        FadeFactor := 0.0;
        Break; // Фон полностью черный, выходим из интро в игру!
      end;
    end;

    // Возможность пропустить интро нажатием Space, Enter или кликом
    if IsKeyPressed(KEY_SPACE) or IsKeyPressed(KEY_ENTER) or IsMouseButtonPressed(MOUSE_LEFT_BUTTON) or (GetGamepadButtonPressed > 0) then
    begin
      if IntroState < 4 then
        IntroState := 4; // Если скипнули до конца анимации, сразу начинаем затемнять фон
      // При скипе затемняем быстрее (скорость увеличивается в 3 раза)
      FadeFactor := FadeFactor - (3.6 * DeltaTime);
    end;

    // --- DRAW INTRO ---
    BeginDrawing();

    // 1. Отрисовка фона с интерполяцией цвета
    if IntroState = 4 then
    begin
      // RAYWHITE в Raylib это (245, 245, 245, 255).
      // Используем 245, чтобы не было резкого скачка яркости при переходе.
      bgColor.r := Byte(Round(245.0 * FadeFactor));
      bgColor.g := Byte(Round(245.0 * FadeFactor));
      bgColor.b := Byte(Round(245.0 * FadeFactor));
      bgColor.a := 255;
      ClearBackground(bgColor);
    end
    else
    begin
      ClearBackground(RAYWHITE);
    end;

    // 2. Отрисовка самого логотипа (только пока он виден, в состояниях 0..3)
    if IntroState <= 3 then
    begin
      if IntroState = 0 then
      begin
        // Мигание с периодом 0.5 секунды (было 15 кадров при 60 FPS)
        if (Trunc(IntroTimer / 0.25) mod 2) = 0 then
          DrawRectangle(IntroLogoPositionX, IntroLogoPositionY, 16, 16, BLACK);
      end
      else if IntroState = 1 then
      begin
        DrawRectangle(IntroLogoPositionX, IntroLogoPositionY, IntroTopSideRecWidth, 16, BLACK);
        DrawRectangle(IntroLogoPositionX, IntroLogoPositionY, 16, IntroLeftSideRecHeight, BLACK);
      end
      else if IntroState = 2 then
      begin
        DrawRectangle(IntroLogoPositionX, IntroLogoPositionY, IntroTopSideRecWidth, 16, BLACK);
        DrawRectangle(IntroLogoPositionX, IntroLogoPositionY, 16, IntroLeftSideRecHeight, BLACK);
        DrawRectangle(IntroLogoPositionX + 240, IntroLogoPositionY, 16, IntroRightSideRecHeight, BLACK);
        DrawRectangle(IntroLogoPositionX, IntroLogoPositionY + 240, IntroBottomSideRecWidth, 16, BLACK);
      end
      else if IntroState = 3 then
      begin
        DrawRectangle(IntroLogoPositionX, IntroLogoPositionY, IntroTopSideRecWidth, 16, Fade(BLACK, IntroAlpha));
        DrawRectangle(IntroLogoPositionX, IntroLogoPositionY + 16, 16, IntroLeftSideRecHeight - 32, Fade(BLACK, IntroAlpha));
        DrawRectangle(IntroLogoPositionX + 240, IntroLogoPositionY + 16, 16, IntroRightSideRecHeight - 32, Fade(BLACK, IntroAlpha));
        DrawRectangle(IntroLogoPositionX, IntroLogoPositionY + 240, IntroBottomSideRecWidth, 16, Fade(BLACK, IntroAlpha));

        DrawRectangle(GetScreenWidth() div 2 - 112, GetScreenHeight() div 2 - 112, 224, 224, Fade(RAYWHITE, IntroAlpha));
        DrawText(TextSubtext('raylib', 0, IntroLettersCount), GetScreenWidth() div 2 - 44, GetScreenHeight() div 2 + 48, 50, Fade(BLACK, IntroAlpha));
      end;
    end;

    EndDrawing();
  end;

  // Финальная "страховка": если произошел Skip и FadeFactor не успел дойти ровно до 0,
  // принудительно рисуем один черный кадр, чтобы переход в игру был идеально плавным.
  if FadeFactor > 0.0 then
  begin
    BeginDrawing();
    ClearBackground(BLACK);
    EndDrawing();
  end;
end;

procedure PollKeyEvents;
begin
  if IsKeyPressed(KEY_ENTER)  then Key_Ent_Pressed   := true;
  if IsKeyPressed(KEY_ESCAPE) then Key_ESC_Pressed   := true;
  if IsKeyPressed(KEY_PAUSE) or IsKeyPressed(KEY_P) then Key_PAUSE_Pressed := true;
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------

procedure ReadInput;
begin
  input.Up    := IsKeyDown(KEY_UP);
  input.Right := IsKeyDown(KEY_RIGHT) or IsKeyDown(KEY_D) or (GetGamepadAxisMovement(0,GAMEPAD_AXIS_LEFT_X) = 1.0);
  input.Down  := IsKeyDown(KEY_DOWN);
  input.Left  := IsKeyDown(KEY_LEFT) or IsKeyDown(KEY_A) or (GetGamepadAxisMovement(0,GAMEPAD_AXIS_LEFT_X) = -1.0);
  input.B1    := IsKeyDown(KEY_SPACE) or (GetGamepadButtonPressed = 6);
  input.B2    := IsKeyDown(KEY_LEFT_SHIFT) or IsKeyDown(KEY_RIGHT_SHIFT);
  input.PAUSE := Key_PAUSE_Pressed or (GetGamepadButtonPressed = 13);
  input.Ent   := Key_Ent_Pressed or (GetGamepadButtonPressed = 15);
  input.ESC   := Key_ESC_Pressed;
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------

procedure ConsumeKeyEvents;
begin
  if input.PAUSE then Key_PAUSE_Pressed := false;
  if input.Ent   then Key_Ent_Pressed   := false;
  if input.ESC   then Key_ESC_Pressed   := false;
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------

procedure LogicStep;
begin
  ReadInput;

  case GameState of
    gsMenu:         update_Menu;
    gsIntro_ALTA:   update_intro_ALTA;
    gsIntro_pause:  update_intro_pause;
    gsIntro_logo:   update_intro_logo;
    gsIntro_text:   update_Intro_text;
    gsIntro_scroll: update_Intro_scroll;
    gsGame:         update_game;
  end;

  ConsumeKeyEvents;
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
procedure Render;
begin
  BeginDrawing();
  ClearBackground(BLACK);

  case GameState of
    gsMenu:         render_Menu;
    gsIntro_ALTA:   render_intro_ALTA;
    gsIntro_pause:  render_intro_ALTA;
    gsIntro_logo:   render_intro_logo;
    gsIntro_text:   render_Intro_text;
    gsIntro_scroll: render_Intro_scroll;
    gsGame:         render_game;
  end;

  EndDrawing();
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
procedure LoadHighScore;
var
  f: TextFile;
begin
  if FileExists('cr.hsc') then
  begin
    AssignFile(f, 'cr.hsc');
    Reset(f);
    Read(f, player.hiscore);
    CloseFile(f);
  end
  else
    player.hiscore := 0;
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
var
  acc:   Double;
  dt:    Double;
  steps: Integer;
  Icn: TImage;
{$R *.res}

begin
  // Инициализация окна
  SetConfigFlags(FLAG_VSYNC_HINT);
  InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, 'SWGalaxian');
 // SetTargetFps(60);


  Icn := LoadImage('data/art.png');
  SetWindowIcons(@Icn,1);
 // UnloadImage(Icn);
  // Инициализация аудио
  InitAudioDevice();



  randomize;

  // Инициализация данных
  tsl := TStringList.Create;

  logo_y    := 700;
  introfade := 0;
  dbl       := 1;

  // Загрузка игровых данных
  LoadData;

  // Инициализация игры
  GameState := gsMenu;
  Init_player(true);

  // Загрузка рекорда
  LoadHighScore;

  SwitchMusic(MenuMusic);  // Переключаемся на интро музыку


  acc := 0.0;

 // PlayIntro();

  SetExitKey(KEY_NULL);  // Отключаем выход по ESC
  while not WindowShouldClose() do
  begin
  //  if IsKeyPressed(KEY_P) then takeScreenShot(PAnsiChar('sc' + Inttostr(random(9999)) +'.png' ));
    dt := GetFrameTime();
    if dt > 0.25 then dt := 0.25;  // лучше перебздеть

    // Опрашиваем клавиши
    PollKeyEvents;


       // Обновляем текущую музыку
   if MusicInitialized then
      UpdateMusicStream(CurrentMusic);

    if GameState = gsIntro_text then
       UpdateCamera(@camera, CAMERA_CUSTOM);

   //Накапливаем время для логики
    acc := acc + dt;

   // Выполняем логику фиксированными шагами по 1/60
    steps := 0;
    while (acc >= LOGIC_STEP) and (steps < 4) do
    begin
      LogicStep;
      acc := acc - LOGIC_STEP;
      Inc(steps);
    end;

    // Защита от "спирали смерти"
    if steps = 4 then
      acc := 0.0;

    //Рендер каждый кадр
    DrawFPS(10,10);
    Render;
  end;

  // Освобождение ресурсов
  tsl.Free;

  // Закрытие аудио
  CloseAudioDevice();
  UnloadAllResources;
  // Закрытие окна
  CloseWindow();
end.
