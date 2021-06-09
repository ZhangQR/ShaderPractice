using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class EdgeDetection : MonoBehaviour
{
    public Shader edgeDetectShader;
    private Material edgeDetectMaterial = null;

    [Range(0.0f, 1.0f)]
    public float edgesOnly = 0.0f;
    [Range(1.0f, 5.0f)]
    public float edgeLevel = 1.0f;
    public Color edgeColor = Color.black;
    public Color backgroundColor = Color.white;

    public Material EdgeDetectMaterial
    {
        get
        {
            if (edgeDetectMaterial == null)
            {
                if (edgeDetectShader.isSupported)
                    edgeDetectMaterial = new Material(edgeDetectShader);
            }
            return edgeDetectMaterial;
        }
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (EdgeDetectMaterial != null)
        {
            EdgeDetectMaterial.SetFloat("_EdgeOnly", edgesOnly);
            EdgeDetectMaterial.SetColor("_EdgeColor", edgeColor);
            EdgeDetectMaterial.SetColor("_BackgroundColor", backgroundColor);
            EdgeDetectMaterial.SetFloat("_EdgeLevel", edgeLevel);


            Graphics.Blit(src, dest, EdgeDetectMaterial);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }


}
