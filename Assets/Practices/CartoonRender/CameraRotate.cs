using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraRotate : MonoBehaviour
{
    public float RotateSpeed;
    private void Update()
    {
        transform.Rotate(Vector3.up * RotateSpeed, Space.Self);
    }
}
