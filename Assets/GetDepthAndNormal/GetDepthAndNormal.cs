using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GetDepthAndNormal : MonoBehaviour
{
    private Camera _camera;
    public Shader getDepthAndNormalShader;
    public bool IsGetDepth = default;
    private Material getDepthAndNormalMaterial = null;

    public Material GetDepthAndNormalMaterial
    {
        get
        {
            if (getDepthAndNormalMaterial == null)
            {
                if (getDepthAndNormalShader.isSupported)
                    getDepthAndNormalMaterial = new Material(getDepthAndNormalShader);
            }
            return getDepthAndNormalMaterial;
        }
    }

    // Start is called before the first frame update
    void Start()
    {
        _camera = GetComponent<Camera>();
        
        // Í¬Ê±¿ªÆô
        _camera.depthTextureMode |= DepthTextureMode.DepthNormals;
        _camera.depthTextureMode |= DepthTextureMode.Depth;
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (GetDepthAndNormalMaterial != null)
        {
            GetDepthAndNormalMaterial.SetInt("_IsGetDepth", IsGetDepth.CompareTo(false));
            Graphics.Blit(src, dest, GetDepthAndNormalMaterial);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
