Shader "ZhangQr/PostProcess/MotionBlurWithDepth"
{
	Properties 
    {
		_MainTex ("MainTex", 2D) = "white" {}
	}
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        CGINCLUDE
        #include "UnityCG.cginc"
        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct v2f
        {
            float2 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
        };

        sampler2D _MainTex;
        float4 _MainTex_ST;
        uint _BlurAmount;
        float _BlurInterval;
        sampler2D _CameraDepthTexture;
        float4x4 _PreviousVPTranform;
        float4x4 _CurrentInverseVPTranform;
        float2 _MainTex_TexelSize;


        v2f vert (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            float2 uv = v.uv;
                
            #if UNITY_UV_STARTS_AT_TOP
            if (_MainTex_TexelSize.y < 0)
                uv.y = 1 - uv.y;
            #endif
                
            o.uv = TRANSFORM_TEX(uv, _MainTex);
            return o;
        }

        fixed4 frag (v2f i) : SV_Target
        {
            float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
            float depth = Linear01Depth(d);
            
            // �� (i.uv,depth) ӳ��� (-1,1) �ķ�Χ��Ҳ���Ǳ�׼�豸���
            float3 NDCposition = float3(i.uv.x * 2 - 1,i.uv.y * 2 - 1,depth * 2 -1);
            
            // ͨ�� VP ������󣬱����������
            float4 currentWorldPosition = mul(_CurrentInverseVPTranform,float4(NDCposition,1));

            // �����˹�һ��
            currentWorldPosition /= currentWorldPosition.w;
            
            float4 PreviousNDCPosition = mul(_PreviousVPTranform,currentWorldPosition);

            PreviousNDCPosition /= PreviousNDCPosition.w;

            // ����ٶȣ�����Ҫ PreviousNDCPosition.xy / 2 + 0.5f ���������� uv��
            float2 velocity = (NDCposition.xy - PreviousNDCPosition.xy)/2.0f;

            fixed3 col = fixed3(0,0,0);
            float2 uv = i.uv;

            // ���ݲ���𽥱䵭����Ҳ��֤������ɫ��ʧ�棬���򵥵ķ�ʽ�ǲ���Ȩ��ӣ����ֱ�ӳ�
            float Total = _BlurAmount * (_BlurAmount - 1) / 2;
            for(uint i = 0 ; i < _BlurAmount ; i++)
            {
                fixed3 c = tex2D(_MainTex,uv + velocity * _BlurInterval * i);
                col += c * (_BlurAmount - 1 - i)/Total;
            }

            return fixed4(col,1);
        }
        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
}
