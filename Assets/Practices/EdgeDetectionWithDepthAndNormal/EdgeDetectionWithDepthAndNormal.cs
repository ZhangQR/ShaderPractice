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

    public float sensitivityNormals = default;
    public bool UseDepth;
    public bool UseNormal;

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

    // Ĭ�� OnRenderImage �����ִ��
    // ImageEffectOpaque ���������� Background��Geometry��AlphaTest �� Transparent ֮�䣨2500��ִ��
    // Ҳ����ֻ�Բ�͸��������������
    [ImageEffectOpaque]
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (EdgeDetectMaterial != null)
        {
            EdgeDetectMaterial.SetFloat("_EdgeOnly", edgesOnly);
            EdgeDetectMaterial.SetInt("_UseDepth", UseDepth.CompareTo(false)); 
            EdgeDetectMaterial.SetInt("_UseNormal", UseNormal.CompareTo(false));
            EdgeDetectMaterial.SetColor("_EdgeColor", edgeColor);
            EdgeDetectMaterial.SetColor("_BackgroundColor", backgroundColor);
            EdgeDetectMaterial.SetFloat("_SampleDistance", sampleDistance);
            EdgeDetectMaterial.SetVector("_Sensitivity", new Vector4(sensitivityDepth,sensitivityNormals,0.0f, 0.0f));

            Graphics.Blit(src, dest, EdgeDetectMaterial);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
