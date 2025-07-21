//
//  main.mm
//  MyApp
//
//  Created by Gabriele Vierti on 20/07/25.
//

#include "application.hpp"

int main(int argc, const char * argv[])
{
    Application* app = new Application(800, 600, "App");
    
    app->Init();
    app->Run();
    app->Cleanup();
    
    delete app;
    
    return 0;
}
