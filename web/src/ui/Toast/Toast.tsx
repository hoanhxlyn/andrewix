import { Text } from "react-aria-components/Text";
import {
  UNSTABLE_Toast as AriaToast,
  UNSTABLE_ToastContent as ToastContent,
  UNSTABLE_ToastQueue as ToastQueue,
  UNSTABLE_ToastRegion as ToastRegion,
} from "react-aria-components/Toast";
import { Button } from "@/ui/Button";
import Icons from "@/ui/Icon";
import * as s from "./Toast.css";

/** What a toast says: a line, and a detail under it when there is one to give. */
export interface ToastMessage {
  title: string;
  description?: string;
}

// One queue for the app, since a toast outlives the component that asked for it.
const queue = new ToastQueue<ToastMessage>({ maxVisibleToasts: 3 });

/** How long a toast stays before it goes away on its own, in milliseconds. */
const TIMEOUT = 5000;

/** Shows a toast for a few seconds over the page. */
export function notify(message: ToastMessage): void {
  queue.add(message, { timeout: TIMEOUT });
}

/** The region toasts appear in; mounted once, it shows nothing until one is queued. */
export function Toaster() {
  return (
    <ToastRegion queue={queue} className={s.region}>
      {({ toast }) => (
        <AriaToast toast={toast} className={s.toast}>
          <ToastContent className={s.content}>
            <Text slot="title" className={s.title}>
              {toast.content.title}
            </Text>
            {toast.content.description !== undefined && (
              <Text slot="description" className={s.description}>
                {toast.content.description}
              </Text>
            )}
          </ToastContent>
          <Button
            variant="icon"
            icon={<Icons.Close />}
            aria-label="Close"
            onPress={() => queue.close(toast.key)}
          />
        </AriaToast>
      )}
    </ToastRegion>
  );
}
