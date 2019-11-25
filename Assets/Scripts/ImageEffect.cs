using UnityEngine;

[RequireComponent(typeof(Camera))]
public class ImageEffect : MonoBehaviour
{
    [SerializeField]
    private Shader[] shaders;
    private Material material;

    private int shaderIndex = 0;

    private void Awake()
    {
        material = new Material(shaders[shaderIndex]);
    }

    private void Update()
    {
        if (Input.anyKeyDown)
        {
            if (shaderIndex + 1 < shaders.Length)
            {
                shaderIndex++;
            }
            else
            {
                shaderIndex = 0;
            }
            material = new Material(shaders[shaderIndex]);
        }
    }

    // OnRenderImage() is called when the camera has finished rendering.
    private void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        Graphics.Blit(src, dst, material);
    } 
}
