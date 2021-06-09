using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class ColorCorrectCtl : MonoBehaviour
{
    public Shader colorCorrectShader;
    private Material material;

    [Range(0, 2)]
    public float brightness = 1;

    [Range(0, 2)]
    public float saturation = 1;

    [Range(0, 2)]
    public float contrast = 1;


    // Use this for initialization
    private void Start()
    {
        Init();
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            material.SetFloat("_Brightness", brightness);
            material.SetFloat("_Saturation", saturation);
            material.SetFloat("_Contrast", contrast);
            Graphics.Blit(src, dest, material);
        }
        else
        {
            // 不做任何操作
            Graphics.Blit(src, dest);
        }
    }


    /// <summary>
    /// 检查 Shader 是否可用并且创造材质球
    /// </summary>
    /// <returns></returns>
    private bool Init()
    {
        if (colorCorrectShader.isSupported)
        {
            material = new Material(colorCorrectShader);
            return true;
        }
        else
        {
            Debug.LogError("Shader 不支持", gameObject);
            return false;
        }
    }
}
