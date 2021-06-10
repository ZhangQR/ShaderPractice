using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlurWithDepth : MonoBehaviour
{
	public Shader MotionBlurShader;
	private Material _motionBlurMaterial = null;
	private Camera _camera;

	public Material MotionBlurMaterial
	{
		get
		{
			if (_motionBlurMaterial == null)
			{
				if (MotionBlurShader.isSupported)
				{
					_motionBlurMaterial = new Material(MotionBlurShader);

				}
			}
			return _motionBlurMaterial;
		}
	}

	private void Awake()
	{
		_camera = GetComponent<Camera>();
	}

	public int BlurAmount = default;	
	
	public float BlurInterval = default;

	//private RenderTexture accumulationTexture;

	private void OnEnable()
	{
		_camera.depthTextureMode |= DepthTextureMode.Depth;
	}

	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (MotionBlurMaterial != null)
		{
			MotionBlurMaterial.SetMatrix("_PreviousVPTranform", _camera.previousViewProjectionMatrix);
			Matrix4x4 currentVP = _camera.projectionMatrix * _camera.worldToCameraMatrix;
			MotionBlurMaterial.SetMatrix("_CurrentInverseVPTranform", currentVP.inverse);
			MotionBlurMaterial.SetInt("_BlurAmount", BlurAmount);
			MotionBlurMaterial.SetFloat("_BlurInterval", BlurInterval);
			Graphics.Blit(src, dest, MotionBlurMaterial);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}
}
