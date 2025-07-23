// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#include <Metal/Metal.hpp>

#include "texture-2D.hpp"

Texture2D::Texture2D(const char* filepath, MTL::Device* metalDevice)
    :m_Image(new Image(filepath))
{
    MTL::TextureDescriptor* textureDescriptor = MTL::TextureDescriptor::alloc()->init();
    
    textureDescriptor->setPixelFormat(MTL::PixelFormatRGBA8Unorm);
    textureDescriptor->setWidth(m_Image->GetWidth());
    textureDescriptor->setHeight(m_Image->GetHeight());

    m_Texture = metalDevice->newTexture(textureDescriptor);

    MTL::Region region = MTL::Region(0, 0, 0, m_Image->GetWidth(), m_Image->GetHeight(), 1);
    NS::UInteger bytesPerRow = 4 * m_Image->GetWidth();

    m_Texture->replaceRegion(region, 0, m_Image->GetData(), bytesPerRow);

    textureDescriptor->release();
}

void Texture2D::Cleanup()
{
    if(m_Image)
    {
        m_Image->Cleanup();
        delete m_Image;
    }
    
    m_Texture->release();
}
