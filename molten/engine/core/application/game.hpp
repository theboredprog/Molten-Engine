// game.hpp

class Application;
class Renderer2D;

#pragma once

class Game
{
protected:
    Application* m_Application = nullptr;
    
public:
    
    virtual ~Game() = default;
    
    void SetApplication(Application* app) { m_Application = app; }
    
    // Access renderer from game
    inline Renderer2D* GetRenderer() const
    {
        return m_Application ? m_Application->GetRenderer2D() : nullptr;
    }
    
    // Called once at startup
    virtual void OnStart() = 0;
    
    // Called every frame, dt in seconds
    virtual void OnUpdate(float dt) = 0;
    
    // Called before shutdown
    virtual void OnShutdown() = 0;
};
