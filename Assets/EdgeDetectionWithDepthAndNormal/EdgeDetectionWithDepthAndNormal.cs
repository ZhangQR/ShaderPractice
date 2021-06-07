using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class EdgeDetectionWithDepthAndNormal : MonoBehaviour
{
    public Shader edgeDetectShader;
    private Material edgeDetectMaterial = null;
    [Range(0.0f, 1.0f)]
    public float edgesOnly = 0.0f;

    public Color edgeColor = Color.black;

    public Color backgroundColor = Color.white;

    public float sampleDistance = 1.0f;

    public float sensitivityDepth = 1.0f;

    public float sensitivityNormals = 1.0f;

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

    private void Start()
    {
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    // 默认 OnRenderImage 在最后执行
    // ImageEffectOpaque 可以让其在 Background、Geometry、AlphaTest 与 Transparent 之间（2500）执行
    // 也就是只对不透明的物体进行描边
    [ImageEffectOpaque]
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (EdgeDetectMaterial != null)
        {
            EdgeDetectMaterial.SetFloat("_EdgeOnly", edgesOnly);
            EdgeDetectMaterial.SetColor("_EdgeColor", edgeColor);
            EdgeDetectMaterial.SetColor("_BackgroundColor", backgroundColor);
            EdgeDetectMaterial.SetFloat("_SampleDistance", sampleDistance);
            EdgeDetectMaterial.SetVector("_Sensitivity", new Vector4(sensitivityNormals, sensitivityDepth, 0.0f, 0.0f));

            Graphics.Blit(src, dest, EdgeDetectMaterial);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
