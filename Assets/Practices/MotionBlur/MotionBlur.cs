using UnityEngine;
using System.Collections;

public class MotionBlur : MonoBehaviour
{

	public Shader MotionBlurShader;
	private Material _motionBlurMaterial = null;

	public Material material
	{
		get
		{
			if(_motionBlurMaterial == null)
            {
                if (MotionBlurShader.isSupported)
                {
					_motionBlurMaterial = new Material(MotionBlurShader);

				}
            }
				return _motionBlurMaterial;
		}
	}

	[Range(0.1f, 0.9f)]
	public float BlurAmount = 0.5f;

	//private RenderTexture accumulationTexture;

	void OnDisable()
	{
		// DestroyImmediate(accumulationTexture);
	}

	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (material != null)
		{
			//if (accumulationTexture == null || accumulationTexture.width != src.width || accumulationTexture.height != src.height)
			//{
			//	DestroyImmediate(accumulationTexture);
			//	accumulationTexture = new RenderTexture(src.width, src.height, 0);
			//	accumulationTexture.hideFlags = HideFlags.HideAndDontSave;
			//	Graphics.Blit(src, accumulationTexture);
			//}

			material.SetFloat("_BlurAmount",BlurAmount);

			Graphics.Blit(src, dest,material);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}
}