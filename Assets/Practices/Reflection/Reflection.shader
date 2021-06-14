Shader "ZhangQr/Reflection"
{
    Properties
    {
        _MainCube("MainCube",Cube) = "_Skybox"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 worldPosition : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
            };

            samplerCUBE _MainCube;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                //o.normal = v.normal;
                o.worldPosition = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //float3 worldNormal = UnityObjectToWorldNormal(i.normal);
                float3 cameraModlePosition = mul(unity_WorldToObject,_WorldSpaceCameraPos);
                float3 worldSpaceViewDir = UnityWorldSpaceViewDir(i.worldPosition);
                float3 reflectDir = reflect(-worldSpaceViewDir,i.worldNormal);
                fixed4 col = texCUBE(_MainCube,reflectDir);
                return col;
            }
            ENDCG
        }
    }
}
