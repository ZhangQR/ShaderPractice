Shader "ZhangQr/Glass"
{
    Properties
    {
        _NormalMap("NormalMap",2D) = "white"{}
        _MainTexure("MainTexture",2D) = "white"{}
        _EnvirnmentCube("EnvirnmentCube",Cube) = "SkyBox"{}
        _RelectionRatio("RelectionRatio",float) = 1
        _RefractionRatio("RefractionRatio",float) = 1
        _RefractionDistortion("RefractionDistortion",float) = 1
    }
    SubShader
    {
        // 透明保证在此之前场景内其他物品都被渲染（折射需要）
        Tags { "RenderType"="Opaque" "Queue" = "Transparent"}
        LOD 100

        GrabPass{"_RefractionTex"}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            sampler2D _NormalMap;
            float4 _NormalMap_ST;
            sampler2D _MainTexure;
            float4 _MainTexure_ST;
            sampler2D _RefractionTex;
            samplerCUBE _EnvirnmentCube;
            float _RelectionRatio;
            float _RefractionRatio;
            float _RefractionDistortion;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
                float4 screenUV : TEXCOORD1;
                float3 worldPosition : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenUV = ComputeGrabScreenPos(o.vertex);
                o.normal = v.normal;
                o.tangent = v.tangent;
                o.uv = v.uv;
                o.worldPosition = mul((float3x3)unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 diffuse = tex2D(_MainTexure,i.uv);
                
                // 需要把切线空间下的法线转换到世界坐标
                fixed3 tangentNormal = UnpackNormal(tex2D(_NormalMap,i.uv)); // 如果贴图设置为了法线格式，那么就要调用这个方法
                //fixed3 tangentNormal = fixed3(0,0,1); // 用来测试的
                //fixed3 tangentNormal = tex2D(_NormalMap,i.uv) * 2 - 1;  // 如果贴图没有设置为法线格式，那么这么写就行(设置了也可以这么写)

                //把法线从切线空间转换到世界坐标
                float3 worldSpaceX = normalize(mul((float3x3)unity_ObjectToWorld,i.tangent));
                float3 worldSpaceZ = normalize(mul(i.normal,(float3x3)unity_WorldToObject));
                float3 worldSpaceY = cross(worldSpaceZ,worldSpaceX)*i.tangent.w;
                float3x3 transformMatrix = transpose(float3x3(worldSpaceX,worldSpaceY,worldSpaceZ));
                float3 worldSpaceNormal = mul(transformMatrix,tangentNormal);

                // 根据法线反射环境
                float3 worldSpaceViewDir = normalize(UnityWorldSpaceViewDir(i.worldPosition));
                float3 relectionDir = reflect(-worldSpaceViewDir,worldSpaceNormal);
                fixed3 relectionCol = texCUBE(_EnvirnmentCube,relectionDir);

                // 计算折射
                float2 refractionOffset = i.screenUV.xy/i.screenUV.w;
                refractionOffset.xy += _RefractionDistortion * tangentNormal.xy;
                fixed3 refractionCol = tex2D(_RefractionTex,refractionOffset).xyz;
                
                // 混合自身贴图、反射、折射
                fixed3 refractionAndReflection = refractionCol * _RefractionRatio + (1 - _RefractionRatio) * relectionCol;
                fixed3 finalCol = diffuse * _RelectionRatio + (1 - _RelectionRatio) * refractionAndReflection; 

                // 验证法线转换是否正确
                //return fixed4(worldSpaceNormal.xyz * 0.5f + 0.5f,1);
                //return fixed4(worldSpaceNormal,1);

                // 最后输出
                return fixed4(finalCol,0);
            }
            ENDCG
        }
    }
}
