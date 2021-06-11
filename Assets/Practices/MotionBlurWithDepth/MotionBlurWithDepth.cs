using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlurWithDepth : MonoBehaviour
{
	public Shader MotionBlurShader;
	private Material _motionBlurMaterial = null;
	private Camera _camera;
	private Matrix4x4 _previousVPTransform = Matrix4x4.identity;
	public int BlurAmount = default;

	[Range(0.01f,0.1f)]
	public float BlurInterval = default;

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

	private void OnEnable()
	{
		_camera.depthTextureMode |= DepthTextureMode.Depth;
	}

	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (MotionBlurMaterial != null)
		{
			// 用这个效果不太对
			// MotionBlurMaterial.SetMatrix("_PreviousVPTranform", _camera.previousViewProjectionMatrix);
			
			MotionBlurMaterial.SetMatrix("_PreviousVPTranform",_previousVPTransform);
			Matrix4x4 currentVP = _camera.projectionMatrix * _camera.worldToCameraMatrix;
			MotionBlurMaterial.SetMatrix("_CurrentInverseVPTranform", currentVP.inverse);
			_previousVPTransform = currentVP;
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
