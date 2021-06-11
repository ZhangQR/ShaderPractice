using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GlobalFog : MonoBehaviour
{
    public Shader GlobalFogShader = default;
    public Color FogColor = default;
    public float FogMinHeight = default;
    public float FogMaxHeight = default;
    [Range(0,1)]
    public float FogDensity = default;
    private Material _globalFogMaterial;

    private Camera _camera;

    private void Awake()
    {
        _camera = GetComponent<Camera>();
    }

    private void OnEnable()
    {
        _camera.depthTextureMode |= DepthTextureMode.Depth;
    }

    public Material GlobalFogMaterial
    {
        get
        {
            if(_globalFogMaterial == null)
            {
                if (GlobalFogShader.isSupported)
                {
                    _globalFogMaterial = new Material(GlobalFogShader);
                }
            }
            return _globalFogMaterial;
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (GlobalFogMaterial != null)
        {
            float near = _camera.nearClipPlane;
            float fov = _camera.fieldOfView;
            float aspect = _camera.aspect;

            float halfHeight = near * Mathf.Tan(Mathf.Deg2Rad * fov * 0.5f);
            float halfWeight = halfHeight * aspect;

            Vector3 TopRight = GetCameraOffset(halfWeight, halfHeight, near);
            float sacle = TopRight.magnitude / near;

            Vector3 RawTopLeft = GetCameraOffset(-halfWeight, halfHeight, near).normalized * sacle;
            Vector3 RawTopRight = TopRight.normalized * sacle;
            Vector3 RawBottomLeft = GetCameraOffset(-halfWeight, -halfHeight, near).normalized * sacle;
            Vector3 RawBottomRight = GetCameraOffset(halfWeight, -halfHeight, near).normalized * sacle;

            Matrix4x4 interpolatedRays = Matrix4x4.identity;
            interpolatedRays.SetRow(0, RawTopLeft);
            interpolatedRays.SetRow(1, RawTopRight);
            interpolatedRays.SetRow(2, RawBottomLeft);
            interpolatedRays.SetRow(3, RawBottomRight);

            GlobalFogMaterial.SetMatrix("_InterpolatedRays", interpolatedRays);
            GlobalFogMaterial.SetFloat("_MinHeight", FogMinHeight);
            GlobalFogMaterial.SetFloat("_MaxHeight", FogMaxHeight);
            GlobalFogMaterial.SetFloat("_FogDensity", FogDensity);
            GlobalFogMaterial.SetColor("_FogColor", FogColor);

            Graphics.Blit(source, destination, GlobalFogMaterial);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }

    private Vector3 GetCameraOffset(float x,float y,float z)
    {
        return _camera.transform.right * x +
            _camera.transform.up * y +
            _camera.transform.forward * z;
    }
}

