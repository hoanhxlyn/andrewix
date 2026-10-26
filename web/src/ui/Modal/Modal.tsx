import { clsx } from "clsx";
import type { ReactNode } from "react";
import { Dialog } from "react-aria-components/Dialog";
import {
  Modal as AriaModal,
  ModalOverlay,
  type ModalOverlayProps,
} from "react-aria-components/Modal";
import * as s from "./Modal.css";

interface ModalProps
  extends Pick<ModalOverlayProps, "isOpen" | "defaultOpen" | "onOpenChange"> {
  /** Name of the dialog for assistive tech. */
  "aria-label": string;
  /** Called once the closing animation has played, or at once when there is none. */
  onClosed?: () => void;
  /** Sizes and colors the box of the modal. */
  className?: string;
  children: ReactNode;
}

/**
 * A dialog over a scrim. Esc and a press outside the box close it; while open, the page behind
 * does not scroll and focus stays inside.
 */
export function Modal({
  "aria-label": label,
  onClosed,
  className,
  children,
  ...rest
}: ModalProps) {
  return (
    <ModalOverlay
      isDismissable
      className={s.overlay}
      onExit={async (element) => {
        await Promise.allSettled(
          element.getAnimations({ subtree: true }).map((a) => a.finished),
        );
        onClosed?.();
      }}
      {...rest}
    >
      <AriaModal className={clsx(s.modal, className)}>
        <Dialog aria-label={label} className={s.dialog}>
          {children}
        </Dialog>
      </AriaModal>
    </ModalOverlay>
  );
}
