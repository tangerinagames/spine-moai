-------------------------------------------------------------------------------
-- Copyright (c) 2013, Esoteric Software, TangerinaGames
-- All rights reserved.
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
-- 
-- 1. Redistributions of source code must retain the above copyright notice, this
--    list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright notice,
--    this list of conditions and the following disclaimer in the documentation
--    and/or other materials provided with the distribution.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
-- ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
------------------------------------------------------------------------------

Application             = require "hp/core/Application"
Layer                   = require "hp/display/Layer"
Sprite                  = require "hp/display/Sprite"
SpriteSheet             = require "hp/display/SpriteSheet"
MapSprite               = require "hp/display/MapSprite"
BackgroundSprite        = require "hp/display/BackgroundSprite"
Graphics                = require "hp/display/Graphics"
Group                   = require "hp/display/Group"
TextLabel               = require "hp/display/TextLabel"
NinePatch               = require "hp/display/NinePatch"
Mesh                    = require "hp/display/Mesh"
Animation               = require "hp/display/Animation"
Particles               = require "hp/display/Particles"
View                    = require "hp/gui/View"
Button                  = require "hp/gui/Button"
Joystick                = require "hp/gui/Joystick"
Panel                   = require "hp/gui/Panel"
MessageBox              = require "hp/gui/MessageBox"
Scroller                = require "hp/gui/Scroller"
BoxLayout               = require "hp/layout/BoxLayout"
VBoxLayout              = require "hp/layout/VBoxLayout"
HBoxLayout              = require "hp/layout/HBoxLayout"
SceneManager            = require "hp/manager/SceneManager"
InputManager            = require "hp/manager/InputManager"
ResourceManager         = require "hp/manager/ResourceManager"
TextureManager          = require "hp/manager/TextureManager"
FontManager             = require "hp/manager/FontManager"
ShaderManager           = require "hp/manager/ShaderManager"
SoundManager            = require "hp/manager/SoundManager"
PhysicsWorld            = require "hp/physics/PhysicsWorld"
PhysicsBody             = require "hp/physics/PhysicsBody"
PhysicsFixture          = require "hp/physics/PhysicsFixture"
TMXLayer                = require "hp/tmx/TMXLayer"
TMXMap                  = require "hp/tmx/TMXMap"
TMXMapLoader            = require "hp/tmx/TMXMapLoader"
TMXMapView              = require "hp/tmx/TMXMapView"
TMXObject               = require "hp/tmx/TMXObject"
TMXObjectGroup          = require "hp/tmx/TMXObjectGroup"
TMXTileset              = require "hp/tmx/TMXTileset"

return _G -- Dummy module