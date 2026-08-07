unit _draw;

interface

uses _var, rlgl, raylib;

procedure draw(tx: TTexture; x, y, w, h, angle: single);
procedure drawtxt(tx: TTexture; x, y, z, w, h, angle: single; color: TColor);

implementation

//----------------------------------------------------------------------------------------------------------------------------------------------------
procedure draw(tx: TTexture; x, y, w, h, angle: single);
var
  sourceRect, destRect: TRectangle;
  origin: TVector2;
begin
  sourceRect := RectangleCreate(0, 0, tx.width, tx.height);
  destRect := RectangleCreate(x - w/2, y - h/2, w, h);
  origin := Vector2Create(w/2, h/2);
  DrawTexturePro(tx, sourceRect, destRect, origin, angle, WHITE);
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
// ВАРИАНТ 1: Настоящий 3D эффект (Звездные Войны с перспективой)
// ИСПРАВЛЕНА ОШИБКА: Добавлено отключение отсечения задних граней и правильный порядок вершин.
procedure drawtxt(tx: TTexture; x, y, z, w, h, angle: single; color: TColor);
begin
  rlPushMatrix;
    rlTranslatef(x, y, 0.0);
    rlRotatef(-70.0, 1.0, 0.0, 0.0); // Наклоняем плоскость "от" камеры
    rlTranslatef(0.0, z, 0.0);        // Двигаем текст вдоль наклонной плоскости
    rlRotatef(angle, 0.0, 0.0, 1.0);

    rlSetTexture(tx.id);
    rlDisableBackfaceCulling(); // <--- ГЛАВНОЕ ИСПРАВЛЕНИЕ: Разрешаем рендерить "изнанку"

    rlBegin(RL_QUADS);
      rlColor4ub(color.r, color.g, color.b, color.a);
      // Порядок вершин строго ПРОТИВ часовой стрелки (CCW), чтобы грань смотрела на камеру
      rlTexCoord2f(0.0, 1.0); rlVertex3f(-w / 2, -h / 2, 0.0); // Низ-Лево
      rlTexCoord2f(1.0, 1.0); rlVertex3f( w / 2, -h / 2, 0.0); // Низ-Право
      rlTexCoord2f(1.0, 0.0); rlVertex3f( w / 2,  h / 2, 0.0); // Верх-Право
      rlTexCoord2f(0.0, 0.0); rlVertex3f(-w / 2,  h / 2, 0.0); // Верх-Лево
    rlEnd;

    rlSetTexture(0);
    rlEnableBackfaceCulling(); // Возвращаем настройку по умолчанию
  rlPopMatrix;
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
// ВАРИАНТ 2: Через DrawBillboardPro (Текст всегда смотрит в камеру, без эффекта трапеции)
// Используйте эту процедуру вместо drawtxt, если хотите плоский спрайт.
procedure drawtxt_billboard(tx: TTexture; x, y, z, w, h, angle: single; color: TColor);
var
  cam: TCamera;
  source: TRectangle;
  pos, up: TVector3;
  size, origin: TVector2;
begin
  // Создаем ту же камеру, что и в render_intro_text
  cam := Camera3DCreate(Vector3Create(0, 0, 500), Vector3Create(0, 0, 0), Vector3Create(0, 1, 0), 45, 0);
  source := RectangleCreate(0, 0, tx.width, tx.height);
  pos := Vector3Create(x, y, z);
  up := Vector3Create(0, 1, 0);
  size := Vector2Create(w, h);
  origin := Vector2Create(w/2, h/2);

  DrawBillboardPro(cam, tx, source, pos, up, size, origin, angle, color);
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------
end.
