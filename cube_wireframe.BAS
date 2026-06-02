! ==========================================================
!  立方体ワイヤーフレーム  自動回転 ＋ マウス操作
!  十進BASIC for Windows 7.8.7.7 用 (Full BASIC)
!
!  ・常に自動回転し続けます。
!  ・左ボタンを押しながらドラッグすると視点を回せます。
!  ・ドラッグ操作中も自動回転は止まりません
!    (自動回転量を毎フレーム必ず角度に加算し、
!     その上にマウスの移動量を足し込んでいるため)。
!  ・ウィンドウを閉じると終了します。
! ==========================================================

OPTION ARITHMETIC NATIVE      ! 倍精度の高速演算(アニメーション用)

! ---------- 立方体の 8 頂点 (±1,±1,±1) ----------
DIM vx(8), vy(8), vz(8)
DATA -1,-1,-1
DATA  1,-1,-1
DATA  1, 1,-1
DATA -1, 1,-1
DATA -1,-1, 1
DATA  1,-1, 1
DATA  1, 1, 1
DATA -1, 1, 1
FOR i = 1 TO 8
   READ vx(i), vy(i), vz(i)
NEXT i

! ---------- 12 本の辺 (頂点番号のペア) ----------
DIM e1(12), e2(12)
DATA 1,2, 2,3, 3,4, 4,1      ! 手前(z=-1)の面
DATA 5,6, 6,7, 7,8, 8,5      ! 奥  (z= 1)の面
DATA 1,5, 2,6, 3,7, 4,8      ! 前後を結ぶ辺
FOR i = 1 TO 12
   READ e1(i), e2(i)
NEXT i

DIM sx(8), sy(8)             ! 投影後のスクリーン座標

! ---------- 画面の設定 ----------
SET WINDOW -3.2, 3.2, -3.2, 3.2
SET DRAW MODE HIDDEN          ! 裏画面に描き WAIT DELAY で表示(ちらつき防止)

! ---------- 状態変数 ----------
LET angX = 0.5               ! X軸まわりの回転角(ラジアン)
LET angY = 0.6               ! Y軸まわりの回転角(ラジアン)
LET autoX = 0.006            ! 自動回転の増分(1フレームあたり)
LET autoY = 0.013
LET dist  = 5                ! 視点距離(透視投影用)
LET sens  = 0.5              ! マウス感度

LET dragging = 0
LET prevmx = 0
LET prevmy = 0

! ====================== メインループ ======================
DO
   ! ---- マウスをノンブロッキングで読み取る ----
   MOUSE POLL mx, my, mleft, mright
   IF mleft = 1 THEN
      IF dragging = 1 THEN
         ! 前フレームからの移動量だけ回転を加える
         LET angY = angY + (mx - prevmx) * sens
         LET angX = angX - (my - prevmy) * sens
      END IF
      LET prevmx = mx
      LET prevmy = my
      LET dragging = 1
   ELSE
      LET dragging = 0
   END IF

   ! ---- 自動回転(マウス操作中でも必ず加算される) ----
   LET angX = angX + autoX
   LET angY = angY + autoY

   ! ---- 各頂点を回転・透視投影 ----
   LET csx = COS(angX)
   LET snx = SIN(angX)
   LET csy = COS(angY)
   LET sny = SIN(angY)
   FOR i = 1 TO 8
      LET x = vx(i)
      LET y = vy(i)
      LET z = vz(i)
      ! X軸まわりの回転
      LET y2 = y * csx - z * snx
      LET z2 = y * snx + z * csx
      ! Y軸まわりの回転
      LET x2 =  x * csy + z2 * sny
      LET z3 = -x * sny + z2 * csy
      ! 透視投影 (視点に近いほど大きく)
      LET f = dist / (dist - z3)
      LET sx(i) = x2 * f
      LET sy(i) = y2 * f
   NEXT i

   ! ---- 描画 ----
   CLEAR
   FOR k = 1 TO 12
      PLOT LINES: sx(e1(k)), sy(e1(k)); sx(e2(k)), sy(e2(k))
   NEXT k

   WAIT DELAY 0.02            ! 裏画面を表示に転送し、少し待つ
LOOP

END
